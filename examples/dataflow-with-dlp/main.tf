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
  region     = "us-central1"
  dataset_id = "dts_data_ingestion"
}

module "data_ingestion" {
  source                           = "../..//modules/base-data-ingestion"
  bucket_name                      = "bkt-data-ingestion"
  dataset_id                       = local.dataset_id
  org_id                           = var.org_id
  project_id                       = var.project_id
  data_governance_project_id       = var.data_governance_project_id
  region                           = local.region
  bucket_location                  = local.region
  dataset_location                 = local.region
  terraform_service_account        = var.terraform_service_account
  vpc_name                         = "tst-network"
  access_context_manager_policy_id = var.access_context_manager_policy_id
  perimeter_members                = var.perimeter_members
  subnet_ip                        = "10.0.32.0/21"
  cmek_location                    = local.region
  cmek_keyring_name                = "cmek_keyring"
  bucket_force_destroy             = var.bucket_force_destroy
}

resource "random_id" "random_suffix" {
  byte_length = 4
}

//dataflow temp bucket
module "dataflow_tmp_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.1"

  project_id    = var.project_id
  name          = "bkt-${random_id.random_suffix.hex}-tmp-dataflow"
  location      = local.region
  force_destroy = var.bucket_force_destroy

  labels = {
    "enterprise_data_ingest_bucket" = "true"
  }

  depends_on = [
    module.data_ingestion.access_level_name
  ]
}
resource "random_id" "original_key" {
  byte_length = 16
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
    gsutil cp cc_records.csv gs://${module.data_ingestion.data_ingest_bucket_names[0]}
    rm cc_records.csv
EOF

  }

  depends_on = [
    module.data_ingestion.access_level_name
  ]
}

module "de_identification_template" {
  source = "../..//modules/de_identification_template"

  project_id                = var.data_governance_project_id
  terraform_service_account = var.terraform_service_account
  crypto_key                = var.crypto_key
  wrapped_key               = var.wrapped_key
  dlp_location              = local.region
  template_file             = "${path.module}/deidentification.tmpl"
  dataflow_service_account  = module.data_ingestion.dataflow_controller_service_account_email
}

module "dataflow_job" {
  source  = "terraform-google-modules/dataflow/google"
  version = "2.0.0"

  project_id            = var.project_id
  name                  = "dlp_example_${null_resource.download_sample_cc_into_gcs.id}_${random_id.random_suffix.hex}"
  on_delete             = "cancel"
  region                = local.region
  zone                  = "${local.region}-a"
  template_gcs_path     = "gs://dataflow-templates/latest/Stream_DLP_GCS_Text_to_BigQuery"
  temp_gcs_location     = module.dataflow_tmp_bucket.bucket.name
  service_account_email = module.data_ingestion.dataflow_controller_service_account_email
  network_self_link     = module.data_ingestion.network_self_link
  subnetwork_self_link  = module.data_ingestion.subnets_self_links[0]
  ip_configuration      = "WORKER_IP_PRIVATE"
  max_workers           = 5

  parameters = {
    inputFilePattern       = "gs://${module.data_ingestion.data_ingest_bucket_names[0]}/cc_records.csv"
    datasetName            = local.dataset_id
    batchSize              = 1000
    dlpProjectId           = var.project_id
    deidentifyTemplateName = "projects/${var.data_governance_project_id}/locations/${local.region}/deidentifyTemplates/${module.de_identification_template.template_id}"
  }

  depends_on = [
    module.data_ingestion.access_level_name
  ]
}
