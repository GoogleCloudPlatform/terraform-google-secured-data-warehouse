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
  location                    = "us-east4"
  non_confidential_dataset_id = "non_confidential_dataset"
  confidential_dataset_id     = "secured_dataset"
  taxonomy_name               = "secured_taxonomy"
  taxonomy_display_name       = "${local.taxonomy_name}-${random_id.suffix.hex}"
  confidential_table_id       = "irs_990_ein_re_id"
  non_confidential_table_id   = "irs_990_ein_de_id"
  bq_schema_irs_990_ein       = "ein:STRING, name:STRING, ico:STRING, street:STRING, city:STRING, state:STRING, zip:STRING,group:STRING, subsection:STRING, affiliation:STRING, classification:STRING, ruling:STRING, deductibility:STRING, foundation:STRING, activity:STRING, organization:STRING, status:STRING, tax_period:STRING, asset_cd:STRING, income_cd:STRING, filing_req_cd:STRING, pf_filing_req_cd:STRING, acct_pd:STRING, asset_amt:STRING, income_amt:STRING, revenue_amt:STRING, ntee_cd:STRING, sort_name:STRING"
}

resource "random_id" "suffix" {
  byte_length = 4
}

module "secured_data_warehouse" {
  source = "../.."

  org_id                           = var.org_id
  data_governance_project_id       = module.base_projects.data_governance_project_id
  confidential_data_project_id     = module.base_projects.confidential_data_project_id
  non_confidential_data_project_id = module.base_projects.non_confidential_data_project_id
  data_ingestion_project_id        = module.base_projects.data_ingestion_project_id
  sdx_project_number               = module.template_project.sdx_project_number
  terraform_service_account        = var.terraform_service_account
  access_context_manager_policy_id = var.access_context_manager_policy_id
  bucket_name                      = "data-ingestion"
  pubsub_resource_location         = local.location
  location                         = local.location
  trusted_locations                = ["us-locations"]
  dataset_id                       = local.non_confidential_dataset_id
  confidential_dataset_id          = local.confidential_dataset_id
  cmek_keyring_name                = "cmek_keyring"
  delete_contents_on_destroy       = var.delete_contents_on_destroy
  perimeter_additional_members     = var.perimeter_additional_members
  data_engineer_group              = var.data_engineer_group
  data_analyst_group               = var.data_analyst_group
  security_analyst_group           = var.security_analyst_group
  network_administrator_group      = var.network_administrator_group
  security_administrator_group     = var.security_administrator_group

  depends_on = [
    module.base_projects,
    module.iam_projects,
    module.centralized_logging,
    google_project_iam_binding.remove_owner_role,
    google_project_iam_binding.remove_owner_role_from_template
  ]
}

module "de_identification_template" {
  source = "../..//modules/de-identification-template"

  project_id                = module.base_projects.data_governance_project_id
  terraform_service_account = var.terraform_service_account
  crypto_key                = module.tek_wrapping_key.keys[local.kek_key_name]
  wrapped_key               = local.wrapped_key_secret_data
  dlp_location              = local.location
  template_id_prefix        = "de_identification"
  template_file             = "${path.module}/templates/deidentification.tmpl"
  dataflow_service_account  = module.secured_data_warehouse.dataflow_controller_service_account_email
}

module "re_identification_template" {
  source = "../..//modules/de-identification-template"

  project_id                = module.base_projects.data_governance_project_id
  terraform_service_account = var.terraform_service_account
  crypto_key                = module.tek_wrapping_key.keys[local.kek_key_name]
  wrapped_key               = local.wrapped_key_secret_data
  dlp_location              = local.location
  template_id_prefix        = "re_identification"
  template_file             = "${path.module}/templates/reidentification.tmpl"
  dataflow_service_account  = module.secured_data_warehouse.confidential_dataflow_controller_service_account_email
}

resource "google_artifact_registry_repository_iam_member" "docker_reader" {
  provider = google-beta

  project    = module.template_project.project_id
  location   = local.location
  repository = "flex-templates"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse.dataflow_controller_service_account_email}"
}

resource "google_artifact_registry_repository_iam_member" "confidential_docker_reader" {
  provider = google-beta

  project    = module.template_project.project_id
  location   = local.location
  repository = "flex-templates"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse.confidential_dataflow_controller_service_account_email}"
}

resource "google_artifact_registry_repository_iam_member" "python_reader" {
  provider = google-beta

  project    = module.template_project.project_id
  location   = local.location
  repository = "python-modules"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse.dataflow_controller_service_account_email}"
}

resource "google_artifact_registry_repository_iam_member" "confidential_python_reader" {
  provider = google-beta

  project    = module.template_project.project_id
  location   = local.location
  repository = "python-modules"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse.confidential_dataflow_controller_service_account_email}"
}

module "regional_deid" {
  source = "../../modules/dataflow-flex-job"

  project_id              = module.base_projects.data_ingestion_project_id
  name                    = "dataflow-flex-regional-dlp-deid-job-python-query"
  container_spec_gcs_path = module.template_project.python_re_identify_template_gs_path
  job_language            = "PYTHON"
  region                  = local.location
  service_account_email   = module.secured_data_warehouse.dataflow_controller_service_account_email
  subnetwork_self_link    = module.base_projects.data_ingestion_subnets_self_link
  kms_key_name            = module.secured_data_warehouse.cmek_data_ingestion_crypto_key
  temp_location           = "gs://${module.secured_data_warehouse.data_ingestion_dataflow_bucket_name}/tmp/"
  staging_location        = "gs://${module.secured_data_warehouse.data_ingestion_dataflow_bucket_name}/staging/"

  parameters = {
    query                          = "SELECT * FROM [bigquery-public-data:irs_990.irs_990_ein] LIMIT 10000"
    deidentification_template_name = module.de_identification_template.template_full_path
    window_interval_sec            = 30
    batch_size                     = 1000
    dlp_location                   = local.location
    dlp_project                    = module.base_projects.data_governance_project_id
    bq_schema                      = local.bq_schema_irs_990_ein
    output_table                   = "${module.base_projects.non_confidential_data_project_id}:${local.non_confidential_dataset_id}.${local.non_confidential_table_id}"
    dlp_transform                  = "DE-IDENTIFY"
  }
}

resource "time_sleep" "wait_de_identify_job_execution" {
  create_duration = "600s"

  depends_on = [
    module.regional_deid
  ]
}

#####
module "regional_reid" {
  source = "../../modules/dataflow-flex-job"

  project_id              = module.base_projects.confidential_data_project_id
  name                    = "dataflow-flex-regional-dlp-reid-job-python-query"
  container_spec_gcs_path = module.template_project.python_re_identify_template_gs_path
  job_language            = "PYTHON"
  region                  = local.location
  service_account_email   = module.secured_data_warehouse.confidential_dataflow_controller_service_account_email
  subnetwork_self_link    = module.base_projects.confidential_subnets_self_link
  kms_key_name            = module.secured_data_warehouse.cmek_reidentification_crypto_key
  temp_location           = "gs://${module.secured_data_warehouse.confidential_data_dataflow_bucket_name}/tmp/"
  staging_location        = "gs://${module.secured_data_warehouse.confidential_data_dataflow_bucket_name}/staging/"

  parameters = {
    input_table                    = "${module.base_projects.non_confidential_data_project_id}:${local.non_confidential_dataset_id}.${local.non_confidential_table_id}"
    deidentification_template_name = module.re_identification_template.template_full_path
    window_interval_sec            = 30
    batch_size                     = 1000
    dlp_location                   = local.location
    dlp_project                    = module.base_projects.data_governance_project_id
    bq_schema                      = local.bq_schema_irs_990_ein
    output_table                   = "${module.base_projects.confidential_data_project_id}:${local.confidential_dataset_id}.${local.confidential_table_id}"
    dlp_transform                  = "RE-IDENTIFY"
  }

  depends_on = [
    time_sleep.wait_de_identify_job_execution,
    google_bigquery_table.re_id
  ]
}
