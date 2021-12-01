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
  region              = "us-east4"
  location            = "us-east4-a"
  schema_file         = "schema.json"
  transform_code_file = "transform.js"
  dataset_id          = "dts_data_ingestion"
  table_name          = "batch_flow_table"
  cc_file_name        = "cc_10000_records.csv"
  cc_file_path        = "${path.module}/assets"

  httpRequestTemplate = templatefile(
    "${path.module}/httpRequest.tmpl",
    {
      location                            = local.location,
      network_self_link                   = var.network_self_link,
      dataflow_service_account            = module.data_ingestion.dataflow_controller_service_account_email,
      subnetwork_self_link                = var.subnetwork_self_link,
      inputFilePattern                    = "gs://${module.data_ingestion.data_ingestion_bucket_name}/${local.cc_file_name}",
      bigquery_project_id                 = var.non_confidential_data_project_id,
      dataset_id                          = local.dataset_id,
      table_name                          = local.table_name,
      javascriptTextTransformFunctionName = "transform",
      JSONPath                            = "gs://${module.data_ingestion.data_ingestion_dataflow_bucket_name}/code/${local.schema_file}",
      javascriptTextTransformGcsPath      = "gs://${module.data_ingestion.data_ingestion_dataflow_bucket_name}/code/${local.transform_code_file}",
      bigQueryLoadingTemporaryDirectory   = "gs://${module.data_ingestion.data_ingestion_dataflow_bucket_name}/tmp"
    }
  )
}

module "data_ingestion" {
  source                           = "../.."
  org_id                           = var.org_id
  data_governance_project_id       = var.data_governance_project_id
  confidential_data_project_id     = var.confidential_data_project_id
  non_confidential_data_project_id = var.non_confidential_data_project_id
  data_ingestion_project_id        = var.data_ingestion_project_id
  sdx_project_number               = var.sdx_project_number
  terraform_service_account        = var.terraform_service_account
  access_context_manager_policy_id = var.access_context_manager_policy_id
  bucket_name                      = "data-ingestion"
  location                         = local.region
  region                           = local.region
  dataset_id                       = local.dataset_id
  cmek_keyring_name                = "cmek_keyring_${random_id.random_suffix.hex}"
  delete_contents_on_destroy       = var.delete_contents_on_destroy
  perimeter_additional_members     = var.perimeter_additional_members
}

resource "google_storage_bucket_object" "sample_file" {
  name         = local.cc_file_name
  source       = "${local.cc_file_path}/${local.cc_file_name}"
  content_type = "text/csv"
  bucket       = module.data_ingestion.data_ingestion_bucket_name

  depends_on = [
    module.data_ingestion.data_ingestion_access_level_name,
    module.data_ingestion.data_governance_access_level_name,
    module.data_ingestion.confidential_access_level_name
  ]
}

resource "google_storage_bucket_object" "schema" {
  name   = "code/${local.schema_file}"
  source = "${path.module}/${local.schema_file}"
  bucket = module.data_ingestion.data_ingestion_dataflow_bucket_name

  depends_on = [
    module.data_ingestion.data_ingestion_access_level_name,
    module.data_ingestion.data_governance_access_level_name,
    module.data_ingestion.confidential_access_level_name
  ]
}

resource "google_storage_bucket_object" "transform_code" {
  name   = "code/${local.transform_code_file}"
  source = "${path.module}/${local.transform_code_file}"
  bucket = module.data_ingestion.data_ingestion_dataflow_bucket_name

  depends_on = [
    module.data_ingestion.data_ingestion_access_level_name,
    module.data_ingestion.data_governance_access_level_name,
    module.data_ingestion.confidential_access_level_name
  ]
}

data "google_service_account" "scheduler_service_account" {
  account_id = module.data_ingestion.scheduler_service_account_email
}
resource "google_project_iam_member" "scheduler_dataflow_developer" {
  project = var.data_ingestion_project_id
  role    = "roles/dataflow.developer"
  member  = "serviceAccount:${module.data_ingestion.scheduler_service_account_email}"
}

resource "google_project_iam_member" "scheduler_compute_viewer" {
  project = var.data_ingestion_project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${module.data_ingestion.scheduler_service_account_email}"
}

resource "google_service_account_iam_member" "scheduler_sa_user" {
  service_account_id = data.google_service_account.scheduler_service_account.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.terraform_service_account}"
}

resource "google_cloud_scheduler_job" "scheduler" {
  name     = "scheduler-demo"
  schedule = "0 0 * * *"
  # Scheduler need App Engine enabled in the project to run, in the same region where it going to be deployed.
  # If you are using App Engine in us-central, you will need to use as region us-central1 for Scheduler.
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
      service_account_email = module.data_ingestion.scheduler_service_account_email
    }

    # need to encode the string
    body = base64encode(local.httpRequestTemplate)
  }
  depends_on = [
    google_storage_bucket_object.schema,
    google_storage_bucket_object.transform_code,
    google_storage_bucket_object.sample_file
  ]
}
