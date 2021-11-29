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
  region       = "us-east4"
  dataset_id   = "dts_data_ingestion"
  cc_file_name = "cc_10000_records.csv"
  cc_file_path = "${path.module}/assets"
}

resource "random_id" "random_suffix" {
  byte_length = 4
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
  dataset_id                       = local.dataset_id
  cmek_keyring_name                = "cmek_keyring_${random_id.random_suffix.hex}"
  delete_contents_on_destroy       = var.delete_contents_on_destroy
  perimeter_additional_members     = var.perimeter_additional_members
}

resource "random_id" "original_key" {
  byte_length = 16
}

resource "google_storage_bucket_object" "sample_file" {
  name         = local.cc_file_name
  source       = "${local.cc_file_path}/${local.cc_file_name}"
  content_type = "text/csv"
  bucket       = module.data_ingestion.data_ingestion_bucket_name

  depends_on = [
    module.data_ingestion
  ]
}

module "de_identification_template" {
  source = "../..//modules/de-identification-template"

  project_id                = var.data_governance_project_id
  terraform_service_account = var.terraform_service_account
  crypto_key                = var.crypto_key
  wrapped_key               = var.wrapped_key
  dlp_location              = local.region
  template_file             = "${path.module}/deidentification.tmpl"
  dataflow_service_account  = module.data_ingestion.dataflow_controller_service_account_email

  depends_on = [
    module.data_ingestion
  ]
}

resource "google_artifact_registry_repository_iam_member" "docker_reader" {
  provider = google-beta

  project    = var.external_flex_template_project_id
  location   = local.region
  repository = "flex-templates"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.data_ingestion.dataflow_controller_service_account_email}"

  depends_on = [
    module.data_ingestion
  ]
}

module "regional_dlp" {
  source = "../../modules/dataflow-flex-job"

  project_id              = var.data_ingestion_project_id
  name                    = "regional-flex-java-gcs-dlp-bq"
  container_spec_gcs_path = var.de_identify_template_gs_path
  region                  = local.region
  service_account_email   = module.data_ingestion.dataflow_controller_service_account_email
  subnetwork_self_link    = var.subnetwork_self_link
  kms_key_name            = module.data_ingestion.cmek_data_ingestion_crypto_key
  temp_location           = "gs://${module.data_ingestion.data_ingestion_dataflow_bucket_name}/tmp/"
  staging_location        = "gs://${module.data_ingestion.data_ingestion_dataflow_bucket_name}/staging/"
  max_workers             = 5

  parameters = {
    inputFilePattern       = "gs://${module.data_ingestion.data_ingestion_bucket_name}/${local.cc_file_name}"
    bqProjectId            = var.non_confidential_data_project_id
    datasetName            = local.dataset_id
    batchSize              = 1000
    dlpProjectId           = var.data_governance_project_id
    dlpLocation            = local.region
    deidentifyTemplateName = module.de_identification_template.template_full_path

  }

  depends_on = [
    google_artifact_registry_repository_iam_member.docker_reader
  ]
}
