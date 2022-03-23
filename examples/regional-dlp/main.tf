/**
 * Copyright 2022 Google LLC
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
  bq_schema = "book:STRING, author:STRING"
  location  = "us-east4"
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
  bucket_name                      = "dlp-flex-data-ingestion"
  dataset_id                       = "dlp_flex_data_ingestion"
  cmek_keyring_name                = "dlp_flex_data-ingestion"
  pubsub_resource_location         = local.location
  location                         = local.location
  delete_contents_on_destroy       = var.delete_contents_on_destroy
  perimeter_additional_members     = var.perimeter_additional_members
  data_engineer_group              = var.data_engineer_group
  data_analyst_group               = var.data_analyst_group
  security_analyst_group           = var.security_analyst_group
  network_administrator_group      = var.network_administrator_group
  security_administrator_group     = var.security_administrator_group
}

module "de_identification_template_example" {
  source = "../..//modules/de-identification-template"

  project_id                = var.data_governance_project_id
  terraform_service_account = var.terraform_service_account
  dataflow_service_account  = module.data_ingestion.dataflow_controller_service_account_email
  crypto_key                = var.crypto_key
  wrapped_key               = var.wrapped_key
  dlp_location              = local.location
  template_file             = "${path.module}/templates/deidentification.tpl"

  depends_on = [
    module.data_ingestion
  ]
}

resource "google_artifact_registry_repository_iam_member" "docker_reader" {
  provider = google-beta

  project    = var.external_flex_template_project_id
  location   = local.location
  repository = "flex-templates"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.data_ingestion.dataflow_controller_service_account_email}"

  depends_on = [
    module.data_ingestion
  ]
}

resource "google_artifact_registry_repository_iam_member" "python_reader" {
  provider = google-beta

  project    = var.external_flex_template_project_id
  location   = local.location
  repository = "python-modules"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.data_ingestion.dataflow_controller_service_account_email}"

  depends_on = [
    module.data_ingestion
  ]
}

module "regional_dlp" {
  source = "../../modules/dataflow-flex-job"

  project_id              = var.data_ingestion_project_id
  name                    = "regional-flex-python-pubsub-dlp-bq"
  container_spec_gcs_path = var.flex_template_gs_path
  job_language            = "PYTHON"
  region                  = local.location
  service_account_email   = module.data_ingestion.dataflow_controller_service_account_email
  subnetwork_self_link    = var.subnetwork_self_link
  kms_key_name            = module.data_ingestion.cmek_data_ingestion_crypto_key
  temp_location           = "gs://${module.data_ingestion.data_ingestion_dataflow_bucket_name}/tmp/"
  staging_location        = "gs://${module.data_ingestion.data_ingestion_dataflow_bucket_name}/staging/"

  parameters = {
    input_topic                    = "projects/${var.data_ingestion_project_id}/topics/${module.data_ingestion.data_ingestion_topic_name}"
    deidentification_template_name = "${module.de_identification_template_example.template_full_path}"
    dlp_location                   = local.location
    dlp_project                    = var.data_governance_project_id
    bq_schema                      = local.bq_schema
    output_table                   = "${var.non_confidential_data_project_id}:${module.data_ingestion.data_ingestion_bigquery_dataset.dataset_id}.classical_books"
  }

  depends_on = [
    google_artifact_registry_repository_iam_member.docker_reader,
    google_artifact_registry_repository_iam_member.python_reader
  ]
}
