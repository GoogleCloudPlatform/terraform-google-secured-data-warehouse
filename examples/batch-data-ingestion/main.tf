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

locals {
  region              = "us-central1"
  location            = "us-central1-a"
  schema_file         = "schema.json"
  transform_code_file = "transform.js"
  dataset_id          = "dts_data_ingestion"
  table_name          = "batch_flow_table"
  httpRequestTemplate = templatefile(
    "${path.module}/httpRequest.tmpl",
    {
      location                            = local.location,
      network_self_link                   = module.data_ingestion.network_self_link,
      dataflow_service_account            = module.data_ingestion.dataflow_controller_service_account_email,
      subnetwork_self_link                = module.data_ingestion.subnets_self_links[0],
      inputFilePattern                    = "gs://${module.data_ingestion.data_ingest_bucket_names[0]}/cc_records.csv",
      bigquery_project_id                 = var.datalake_project_id,
      dataset_id                          = local.dataset_id,
      table_name                          = local.table_name,
      javascriptTextTransformFunctionName = "transform",
      JSONPath                            = "gs://${module.dataflow_tmp_bucket.bucket.name}/code/${local.schema_file}",
      javascriptTextTransformGcsPath      = "gs://${module.dataflow_tmp_bucket.bucket.name}/code/${local.transform_code_file}",
      bigQueryLoadingTemporaryDirectory   = "gs://${module.dataflow_tmp_bucket.bucket.name}/tmp"
    }
  )
}

module "data_ingestion" {
  source                           = "../.."
  org_id                           = var.org_id
  data_governance_project_id       = var.data_governance_project_id
  privileged_data_project_id       = var.privileged_data_project_id
  datalake_project_id              = var.datalake_project_id
  data_ingestion_project_id        = var.data_ingestion_project_id
  sdx_project_number               = var.sdx_project_number
  terraform_service_account        = var.terraform_service_account
  access_context_manager_policy_id = var.access_context_manager_policy_id
  perimeter_additional_members     = var.perimeter_members
  bucket_name                      = "bkt-data-ingestion"
  location                         = local.region
  vpc_name                         = "tst-network"
  subnet_ip                        = "10.0.32.0/21"
  region                           = local.region
  dataset_id                       = local.dataset_id
  cmek_keyring_name                = "cmek_keyring_${random_id.random_suffix.hex}"
  delete_contents_on_destroy       = var.delete_contents_on_destroy
}


//dataflow temp bucket
module "dataflow_tmp_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.1"

  project_id    = var.data_ingestion_project_id
  name          = "bkt-${random_id.random_suffix.hex}-tmp-dataflow"
  location      = local.region
  force_destroy = var.delete_contents_on_destroy
  encryption    = { "default_kms_key_name" = module.data_ingestion.cmek_ingestion_crypto_key }

  labels = {
    "enterprise_data_ingest_bucket" = "true"
  }

  depends_on = [
    module.data_ingestion.data_ingestion_access_level_name,
    module.data_ingestion.data_governance_access_level_name,
    module.data_ingestion.privileged_access_level_name
  ]
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
    module.data_ingestion.data_ingestion_access_level_name,
    module.data_ingestion.data_governance_access_level_name,
    module.data_ingestion.privileged_access_level_name
  ]
}

resource "google_storage_bucket_object" "schema" {
  name   = "code/${local.schema_file}"
  source = "${path.module}/${local.schema_file}"
  bucket = module.dataflow_tmp_bucket.bucket.name
  depends_on = [
    module.dataflow_tmp_bucket
  ]
}

resource "google_storage_bucket_object" "transform_code" {
  name   = "code/${local.transform_code_file}"
  source = "${path.module}/${local.transform_code_file}"
  bucket = module.dataflow_tmp_bucket.bucket.name
  depends_on = [
    module.dataflow_tmp_bucket
  ]
}


//Scheduler controller service account
module "scheduler_controller_service_account" {
  source       = "terraform-google-modules/service-accounts/google"
  version      = "~> 3.0"
  project_id   = var.data_ingestion_project_id
  names        = ["sa-scheduler-controller"]
  display_name = "Cloud Scheduler controller service account"
  project_roles = [
    "${var.data_ingestion_project_id}=>roles/dataflow.developer",
    "${var.data_ingestion_project_id}=>roles/compute.viewer",
  ]
}

resource "google_cloud_scheduler_job" "scheduler" {
  name     = "scheduler-demo"
  schedule = "0 0 * * *"
  # This needs to be us-central1 even if App Engine is in us-central.
  # You will get a resource not found error if just using us-central.
  region  = local.region
  project = var.data_ingestion_project_id

  http_target {
    http_method = "POST"
    headers = {
      "Accept"       = "application/json"
      "Content-Type" = "application/json"
    }
    uri = "https://dataflow.googleapis.com/v1b3/projects/${var.data_ingestion_project_id}/locations/${local.region}/templates"
    oauth_token {
      service_account_email = module.scheduler_controller_service_account.email
    }

    # need to encode the string
    body = base64encode(local.httpRequestTemplate)
  }
  depends_on = [
    google_storage_bucket_object.schema,
    google_storage_bucket_object.transform_code
  ]
}
