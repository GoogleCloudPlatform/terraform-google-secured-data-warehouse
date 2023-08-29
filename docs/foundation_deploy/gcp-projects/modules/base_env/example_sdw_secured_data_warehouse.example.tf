/**
    * Copyright 2023 Google LLC
    *
    * Licensed under the Apache License, Version 2.0 (the "License");
    * you may not use this file except in compliance with the License.
    * You may obtain a copy of the License at
    *
    *      <http://www.apache.org/licenses/LICENSE-2.0>
    *
    * Unless required by applicable law or agreed to in writing, software
    * distributed under the License is distributed on an "AS IS" BASIS,
    * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    * See the License for the specific language governing permissions and
    * limitations under the License.
    */

locals {
  sdw_app_infra_sa = var.enable_sdw ? local.app_infra_pipeline_service_accounts["${var.business_code}-sdw-app"] : ""

  non_confidential_dataset_id = "non_confidential_dataset"
  confidential_dataset_id     = "secured_dataset"
  confidential_table_id       = "irs_990_ein_re_id"
  non_confidential_table_id   = "irs_990_ein_de_id"

  kek_keyring                        = "kek_keyring"
  kek_key_name                       = "kek_key"
  key_rotation_period_seconds        = "2592000s" #30 days
  secret_name                        = "wrapped_key"
  use_temporary_crypto_operator_role = true

  apis_to_enable = [
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "cloudbilling.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
  docker_repository_url = var.enable_sdw ? "${local.location}-docker.pkg.dev/${module.dataflow_template_project[0].project_id}/${google_artifact_registry_repository.flex_templates[0].name}" : ""
  python_repository_url = var.enable_sdw ? "${local.location}-python.pkg.dev/${module.dataflow_template_project[0].project_id}/${google_artifact_registry_repository.python_modules[0].name}" : ""
}

module "secured_data_warehouse" {
  source = "git::https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse.git?ref=release-please--branches--main"
  # source  = "GoogleCloudPlatform/secured-data-warehouse/google"
  # version = "~> 1.0"

  count = var.enable_sdw ? 1 : 0

  org_id                           = local.org_id
  labels                           = { environment = "prod" }
  data_governance_project_id       = module.data_governance_project[0].project_id
  non_confidential_data_project_id = module.non_confidential_data_project[0].project_id
  confidential_data_project_id     = module.confidential_data_project[0].project_id
  data_ingestion_perimeter         = local.perimeter_name
  data_ingestion_project_id        = module.data_ingestion_project[0].project_id
  sdx_project_number               = module.dataflow_template_project[0].project_number
  terraform_service_account        = data.terraform_remote_state.bootstrap.outputs.projects_step_terraform_service_account_email
  access_context_manager_policy_id = local.access_context_manager_policy_id
  bucket_name                      = "dwt-data-ing"
  pubsub_resource_location         = local.location
  location                         = local.location
  trusted_locations                = ["us-locations"]
  dataset_id                       = local.non_confidential_dataset_id
  confidential_dataset_id          = local.confidential_dataset_id
  cmek_keyring_name                = "dwt-data-ing"

  confidential_data_dataflow_deployer_identities = [
    "serviceAccount:service-${module.confidential_data_project[0].project_number}@dataflow-service-producer-prod.iam.gserviceaccount.com",
    "serviceAccount:${local.sdw_app_infra_sa}"
  ]

  // provide additional information
  delete_contents_on_destroy = true
  perimeter_additional_members = concat(var.sdw_perimeter_additional_members,
    [
      "serviceAccount:${local.sdw_app_infra_sa}",
      "serviceAccount:service-${module.confidential_data_project[0].project_number}@dataflow-service-producer-prod.iam.gserviceaccount.com",
    ]
  )
  data_engineer_group          = var.data_engineer_group
  data_analyst_group           = var.data_analyst_group
  security_analyst_group       = var.security_analyst_group
  network_administrator_group  = var.network_administrator_group
  security_administrator_group = var.security_administrator_group

  // Set the enable_bigquery_read_roles_in_data_ingestion to true, it will grant to the dataflow controller
  // service account created in the data ingestion project the necessary roles to read from a bigquery table.
  enable_bigquery_read_roles_in_data_ingestion = true

  depends_on = [
    module.data_governance_project,
    module.confidential_data_project,
    module.non_confidential_data_project,
    module.data_ingestion_project,
    module.dataflow_template_project,
  ]
}

resource "google_project_service" "apis_to_enable" {
  for_each = var.enable_sdw ? toset(local.apis_to_enable) : []

  project            = module.dataflow_template_project[0].project_id
  service            = each.key
  disable_on_destroy = false
}

resource "random_id" "suffix" {
  byte_length = 2
}

resource "google_project_service_identity" "cloudbuild_sa" {
  provider = google-beta

  count = var.enable_sdw ? 1 : 0

  project = module.dataflow_template_project[0].project_id
  service = "cloudbuild.googleapis.com"

  depends_on = [
    google_project_service.apis_to_enable
  ]
}

resource "google_project_iam_member" "cloud_build_builder" {

  count   = var.enable_sdw ? 1 : 0
  project = module.dataflow_template_project[0].project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_project_service_identity.cloudbuild_sa[0].email}"
}

resource "google_artifact_registry_repository" "flex_templates" {

  count    = var.enable_sdw ? 1 : 0
  provider = google-beta

  project       = module.dataflow_template_project[0].project_id
  location      = local.location
  repository_id = var.docker_repository_id
  description   = "DataFlow Flex Templates"
  format        = "DOCKER"

  depends_on = [
    google_project_service.apis_to_enable
  ]
}

resource "google_artifact_registry_repository_iam_member" "docker_writer" {

  count    = var.enable_sdw ? 1 : 0
  provider = google-beta

  project    = module.dataflow_template_project[0].project_id
  location   = local.location
  repository = var.docker_repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_project_service_identity.cloudbuild_sa[0].email}"

  depends_on = [
    google_artifact_registry_repository.flex_templates
  ]
}

resource "google_artifact_registry_repository" "python_modules" {

  count    = var.enable_sdw ? 1 : 0
  provider = google-beta

  project       = module.dataflow_template_project[0].project_id
  location      = local.location
  repository_id = var.python_repository_id
  description   = "Repository for Python modules for Dataflow flex templates"
  format        = "PYTHON"
}

resource "google_artifact_registry_repository_iam_member" "python_writer" {

  count    = var.enable_sdw ? 1 : 0
  provider = google-beta

  project    = module.dataflow_template_project[0].project_id
  location   = local.location
  repository = var.python_repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_project_service_identity.cloudbuild_sa[0].email}"

  depends_on = [
    google_artifact_registry_repository.python_modules
  ]
}

resource "google_storage_bucket" "templates_bucket" {

  count    = var.enable_sdw ? 1 : 0
  name     = "bkt-${module.dataflow_template_project[0].project_id}-tpl-${random_id.suffix.hex}"
  location = local.location
  project  = module.dataflow_template_project[0].project_id

  force_destroy               = true
  uniform_bucket_level_access = true

  depends_on = [
    google_project_service.apis_to_enable
  ]
}

resource "google_artifact_registry_repository_iam_member" "docker_reader" {
  provider = google-beta

  count = var.enable_sdw ? 1 : 0

  project    = module.dataflow_template_project[0].project_id
  location   = local.location
  repository = "flex-templates"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse[0].dataflow_controller_service_account_email}"

  depends_on = [
    google_artifact_registry_repository.flex_templates
  ]
}

resource "google_artifact_registry_repository_iam_member" "confidential_docker_reader" {
  provider = google-beta

  count = var.enable_sdw ? 1 : 0

  project    = module.dataflow_template_project[0].project_id
  location   = local.location
  repository = "flex-templates"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse[0].confidential_dataflow_controller_service_account_email}"

  depends_on = [
    google_artifact_registry_repository.flex_templates
  ]
}

resource "google_artifact_registry_repository_iam_member" "python_reader" {
  provider = google-beta

  count = var.enable_sdw ? 1 : 0

  project    = module.dataflow_template_project[0].project_id
  location   = local.location
  repository = "python-modules"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse[0].dataflow_controller_service_account_email}"

  depends_on = [
    google_artifact_registry_repository.flex_templates
  ]
}

resource "google_artifact_registry_repository_iam_member" "confidential_python_reader" {
  provider = google-beta

  count = var.enable_sdw ? 1 : 0

  project    = module.dataflow_template_project[0].project_id
  location   = local.location
  repository = "python-modules"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse[0].confidential_dataflow_controller_service_account_email}"

  depends_on = [
    google_artifact_registry_repository.flex_templates
  ]
}

module "tek_wrapping_key" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 2.2"

  count = var.enable_sdw ? 1 : 0

  project_id           = module.data_governance_project[0].project_id
  labels               = { environment = "dev" }
  location             = local.location
  keyring              = local.kek_keyring
  key_rotation_period  = local.key_rotation_period_seconds
  keys                 = [local.kek_key_name]
  key_protection_level = "HSM"
  prevent_destroy      = false
}
