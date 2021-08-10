/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  dlp_location = "global"
  kms_roles    = toset(["roles/cloudkms.cryptoKeyEncrypter", "roles/cloudkms.cryptoKeyDecrypter"])

}

resource "random_id" "random_suffix" {
  byte_length = 4
}

//storage ingest bucket
module "dataflow-bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.1"

  project_id    = var.project_id
  name          = "bkt-${random_id.random_suffix.hex}-tmp-dataflow"
  location      = "US"
  force_destroy = true

  labels = {
    "enterprise_data_ingest_bucket" = "true"
  }
}

resource "null_resource" "download_sample_cc_into_gcs" {
  provisioner "local-exec" {
    command = <<EOF
    curl http://eforexcel.com/wp/wp-content/uploads/2017/07/1500000%20CC%20Records.zip > cc_records.zip
    unzip cc_records.zip
    rm cc_records.zip
    mv 1500000\ CC\ Records.csv cc_records.csv
    echo "Changing sample file encoding from ISO-8859-1 to UTF-8"
    iconv -f="ISO-8859-1" -t="UTF-8" cc_records.csv > temp_cc_records.csv
    mv temp_cc_records.csv cc_records.csv
    gsutil cp cc_records.csv gs://${module.dataflow-bucket.bucket.name}
    rm cc_records.csv
EOF

  }
}

resource "google_kms_crypto_key_iam_binding" "dlp_encrypters_decrypters" {
  for_each = local.kms_roles

  role          = each.key
  crypto_key_id = var.crypto_key
  members       = ["serviceAccount:${var.dataflow_service_account}"]
}

resource "google_data_loss_prevention_deidentify_template" "de_identify_template" {
  parent       = "projects/${var.project_id}/locations/${local.dlp_location}"
  description  = "De-identifies sensitive content defined in the template with a KMS wrapped CMEK."
  display_name = "De-identification template using a KMS wrapped CMEK"

  deidentify_config {
    info_type_transformations {
      transformations {
        info_types {
          name = "Card Number"
        }
        info_types {
          name = "Card PIN"
        }
        primitive_transformation {
          crypto_replace_ffx_fpe_config {
            crypto_key {
              kms_wrapped {
                wrapped_key     = var.wrapped_key
                crypto_key_name = var.wrapped_key
              }
            }
            common_alphabet = "ALPHA_NUMERIC"
          }
        }
      }
    }
  }
}

module "dataflow-job" {
  source  = "terraform-google-modules/dataflow/google"
  version = "2.0.0"

  project_id            = var.project_id
  name                  = "dlp_example_${null_resource.download_sample_cc_into_gcs.id}_${random_id.random_suffix.hex}"
  on_delete             = "cancel"
  region                = "us-central1"
  zone                  = "us-central1-a"
  template_gcs_path     = "gs://dataflow-templates/latest/Stream_DLP_GCS_Text_to_BigQuery"
  temp_gcs_location     = module.dataflow-bucket.bucket.name
  service_account_email = var.dataflow_service_account
  subnetwork_self_link  = var.subnetwork_self_link
  network_self_link     = var.network_self_link
  ip_configuration      = "WORKER_IP_PRIVATE"
  max_workers           = 5

  parameters = {
    inputFilePattern       = "gs://${module.dataflow-bucket.bucket.name}/cc_records.csv"
    datasetName            = var.dataset_id
    batchSize              = 1000
    dlpProjectId           = var.project_id
    deidentifyTemplateName = google_data_loss_prevention_deidentify_template.de_identify_template.id
  }
}
