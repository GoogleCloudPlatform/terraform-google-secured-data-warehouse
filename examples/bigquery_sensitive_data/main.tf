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
  region                   = "us-east4"
  non_sensitive_dataset_id = "non_sensitive_dataset"
  confidential_dataset_id  = "secured_dataset"
  taxonomy_display_name    = "${var.taxonomy_name}-${random_id.suffix.hex}"
  confidential_table_id    = "${trimsuffix(local.cc_file_name, ".csv")}_re_id"
  kek_keyring              = "kek_keyring_${random_id.suffix.hex}"
  kek_key_name             = "kek_key_${random_id.suffix.hex}"
  cc_file_name             = "cc_100_records.csv"

}

resource "random_id" "suffix" {
  byte_length = 4
}

module "secured_data_warehouse" {
  source = "../.."

  org_id                           = var.org_id
  data_governance_project_id       = var.data_governance_project_id
  privileged_data_project_id       = var.privileged_data_project_id
  datalake_project_id              = var.non_sensitive_project_id
  data_ingestion_project_id        = var.data_ingestion_project_id
  sdx_project_number               = var.sdx_project_number
  terraform_service_account        = var.terraform_service_account
  access_context_manager_policy_id = var.access_context_manager_policy_id
  bucket_name                      = "bkt-data-ingestion"
  location                         = local.region
  region                           = local.region
  dataset_id                       = local.non_sensitive_dataset_id
  confidential_dataset_id          = local.confidential_dataset_id
  cmek_keyring_name                = "cmek_keyring_${random_id.suffix.hex}"
  delete_contents_on_destroy       = var.delete_contents_on_destroy
  perimeter_additional_members     = var.perimeter_additional_members
}


resource "google_storage_bucket_object" "cc_sample" {
  name   = local.cc_file_name
  source = "${path.module}/files/cc_samples/${local.cc_file_name}"
  bucket = module.secured_data_warehouse.data_ingest_bucket_name
}

module "de_identification_template" {
  source = "../..//modules/de_identification_template"

  project_id                = var.data_governance_project_id
  terraform_service_account = var.terraform_service_account
  crypto_key                = var.crypto_key
  wrapped_key               = var.wrapped_key
  dlp_location              = local.region
  template_id_prefix        = "de_identification"
  template_file             = "${path.module}/templates/deidentification.tmpl"
  dataflow_service_account  = module.secured_data_warehouse.dataflow_controller_service_account_email
}

module "re_identification_template" {
  source = "../..//modules/de_identification_template"

  project_id                = var.data_governance_project_id
  terraform_service_account = var.terraform_service_account
  crypto_key                = var.crypto_key
  wrapped_key               = var.wrapped_key
  dlp_location              = local.region
  template_id_prefix        = "re_identification"
  template_file             = "${path.module}/templates/reidentification.tmpl"
  dataflow_service_account  = module.secured_data_warehouse.confidential_dataflow_controller_service_account_email
}

resource "google_artifact_registry_repository_iam_member" "docker_reader" {
  provider = google-beta

  project    = var.external_flex_template_project_id
  location   = local.region
  repository = "flex-templates"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse.dataflow_controller_service_account_email}"
}

resource "google_artifact_registry_repository_iam_member" "confidential_docker_reader" {
  provider = google-beta

  project    = var.external_flex_template_project_id
  location   = local.region
  repository = "flex-templates"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse.confidential_dataflow_controller_service_account_email}"
}

resource "google_dataflow_flex_template_job" "regional_deid" {
  provider = google-beta

  project                 = var.data_ingestion_project_id
  name                    = "regional-flex-java-gcs-dlp-bq"
  container_spec_gcs_path = var.java_de_identify_template_gs_path
  region                  = local.region

  parameters = {
    inputFilePattern       = "gs://${module.secured_data_warehouse.data_ingest_bucket_name}/${local.cc_file_name}"
    bqProjectId            = var.non_sensitive_project_id
    datasetName            = local.non_sensitive_dataset_id
    batchSize              = 1000
    dlpProjectId           = var.data_governance_project_id
    dlpLocation            = local.region
    deidentifyTemplateName = module.de_identification_template.template_full_path
    serviceAccount         = module.secured_data_warehouse.dataflow_controller_service_account_email
    subnetwork             = var.data_ingestion_subnets_self_link
    dataflowKmsKey         = module.secured_data_warehouse.cmek_ingestion_crypto_key
    tempLocation           = "gs://${module.secured_data_warehouse.data_ingest_dataflow_bucket_name}/tmp/"
    stagingLocation        = "gs://${module.secured_data_warehouse.data_ingest_dataflow_bucket_name}/staging/"
    maxNumWorkers          = 5
    usePublicIps           = "false"
  }

  depends_on = [
    google_artifact_registry_repository_iam_member.docker_reader
  ]
}

resource "time_sleep" "wait_de_identify_job_execution" {
  create_duration = "600s"

  depends_on = [
    google_dataflow_flex_template_job.regional_deid
  ]
}

resource "google_dataflow_flex_template_job" "regional_reid" {
  provider = google-beta

  project                 = var.privileged_data_project_id
  name                    = "dataflow-flex-regional-dlp-reid-job"
  container_spec_gcs_path = var.java_re_identify_template_gs_path
  region                  = local.region

  parameters = {
    inputBigQueryTable      = "${var.non_sensitive_project_id}:${local.non_sensitive_dataset_id}.${trimsuffix(local.cc_file_name, ".csv")}"
    outputBigQueryDataset   = local.confidential_dataset_id
    deidentifyTemplateName  = module.re_identification_template.template_full_path
    dlpLocation             = local.region
    dlpProjectId            = var.data_governance_project_id
    privilegedDataProjectId = var.privileged_data_project_id
    serviceAccount          = module.secured_data_warehouse.confidential_dataflow_controller_service_account_email
    subnetwork              = var.privileged_subnets_self_link
    dataflowKmsKey          = module.secured_data_warehouse.cmek_reidentification_crypto_key
    tempLocation            = "gs://${module.secured_data_warehouse.confidential_data_dataflow_bucket_name}/tmp/"
    stagingLocation         = "gs://${module.secured_data_warehouse.confidential_data_dataflow_bucket_name}/staging/"
    usePublicIps            = false
    enableStreamingEngine   = true
  }

  depends_on = [
    time_sleep.wait_de_identify_job_execution,
    google_bigquery_table.re_id
  ]
}
