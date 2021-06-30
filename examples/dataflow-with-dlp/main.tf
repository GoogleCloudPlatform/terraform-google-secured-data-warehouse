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

resource "random_id" "random_suffix" {
  byte_length = 4
}

//storage ingest bucket
module "dataflow-bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.1"

  project_id    = var.project_id
  name          = "bkt-${random_id.random_suffix.hex}-${var.bucket_name}"
  location      = var.bucket_location
  force_destroy = var.bucket_force_destroy

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
    gsutil cp cc_records.csv gs://${module.dataflow-bucket.bucket.name}
    rm cc_records.csv
EOF

  }
  depends_on = [
    module.dataflow-bucket
  ]
}


module "de_identification_template" {
  source = "../..//modules/de_identification_template"

  project_id                = var.project_id
  terraform_service_account = var.terraform_service_account
  crypto_key                = var.crypto_key
  wrapped_key               = var.wrapped_key
  dlp_location              = var.dlp_location
  template_file             = "${path.module}/deidentification.tmpl"
  dataflow_service_account  = var.dataflow_service_account
}


module "dataflow-job" {
  source                = "github.com/terraform-google-modules/terraform-google-dataflow"
  project_id            = var.project_id
  name                  = "dlp_example_${null_resource.download_sample_cc_into_gcs.id}_${random_id.random_suffix.hex}"
  on_delete             = "cancel"
  region                = var.region
  zone                  = var.zone
  template_gcs_path     = "gs://dataflow-templates/latest/Stream_DLP_GCS_Text_to_BigQuery"
  temp_gcs_location     = module.dataflow-bucket.bucket.name
  service_account_email = var.dataflow_service_account
  subnetwork_self_link  = var.subnetwork_self_link
  network_self_link     = var.network_self_link
  ip_configuration      = var.ip_configuration
  max_workers           = 5

  parameters = {
    inputFilePattern       = "gs://${module.dataflow-bucket.bucket.name}/cc_records.csv"
    datasetName            = var.dataset_id
    batchSize              = 1000
    dlpProjectId           = var.project_id
    deidentifyTemplateName = "projects/${var.project_id}/locations/${var.dlp_location}/deidentifyTemplates/${module.de_identification_template.template_id}"
  }

  depends_on = [
    google_compute_firewall.allow_egress_dataflow_workers,
    google_compute_firewall.allow_ingress_dataflow_workers
  ]
}
