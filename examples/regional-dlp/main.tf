
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
  python_repository_id        = "python-modules"
  flex_template_repository_id = "flex-templates"
  kek_keyring                 = "kek_keyring_${random_id.random_suffix.hex}"
  kek_key_name                = "kek_key_${random_id.random_suffix.hex}"
  bq_schema                   = "book:STRING, author:STRING"
}

resource "random_id" "random_suffix" {
  byte_length = 4
}

module "kek" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 1.2"

  project_id      = var.project_id
  location        = var.location
  keyring         = local.kek_keyring
  keys            = [local.kek_key_name]
  prevent_destroy = false
}

resource "random_id" "original_key" {
  byte_length = 16
}

resource "google_kms_secret_ciphertext" "wrapped_key" {
  crypto_key = module.kek.keys[local.kek_key_name]
  plaintext  = random_id.original_key.b64_std
}


module "data_ingestion" {
  source                           = "../..//modules/base-data-ingestion"
  bucket_name                      = "bkt-dlp-flex-ingest"
  dataset_id                       = "dlp_flex_ingest"
  org_id                           = var.org_id
  project_id                       = var.project_id
  data_governance_project_id       = var.project_id
  terraform_service_account        = var.terraform_service_account
  access_context_manager_policy_id = var.access_context_manager_policy_id
  perimeter_additional_members     = var.perimeter_additional_members
  vpc_name                         = "dlp-flex-ingest"
  subnet_ip                        = "10.0.32.0/21"
  region                           = var.location
  dataset_location                 = var.location
  bucket_location                  = var.location
  cmek_location                    = var.location
  cmek_keyring_name                = "dlp_flex_ingest"
}

resource "time_sleep" "wait_90_seconds_for_vpc_sc_propagation" {
  depends_on = [module.data_ingestion]

  create_duration = "90s"
}

module "de_identification_template_example" {
  source = "../..//modules/de_identification_template"

  project_id                = var.project_id
  terraform_service_account = var.terraform_service_account
  dataflow_service_account  = module.data_ingestion.dataflow_controller_service_account_email
  crypto_key                = module.kek.keys[local.kek_key_name]
  wrapped_key               = google_kms_secret_ciphertext.wrapped_key.ciphertext
  dlp_location              = var.location
  template_file             = "${path.module}/deidentification.tmpl"

}

module "flex_dlp_template" {
  source = "../..//modules/flex_template"

  project_id                  = var.project_id
  location                    = var.location
  repository_id               = local.flex_template_repository_id
  python_modules_private_repo = "https://${var.location}-python.pkg.dev/${var.project_id}/${local.python_repository_id}/simple/"
  terraform_service_account   = var.terraform_service_account
  image_name                  = "regional_dlp_flex"
  image_tag                   = "0.1.0"

  template_files = {
    code_file         = "${path.module}/pubsub_dlp_bigquery.py"
    metadata_file     = "${path.module}/metadata.json"
    requirements_file = "${path.module}/requirements.txt"
  }

  module_depends_on = [
    time_sleep.wait_90_seconds_for_vpc_sc_propagation
  ]

}

resource "google_artifact_registry_repository_iam_member" "flex-template-iam" {
  provider = google-beta

  project    = var.project_id
  location   = var.location
  repository = local.flex_template_repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.data_ingestion.dataflow_controller_service_account_email}"

  depends_on = [
    module.flex_dlp_template
  ]
}

module "python_module_repository" {
  source = "../..//modules/python_module_repository"

  project_id                = var.project_id
  location                  = var.location
  repository_id             = local.python_repository_id
  terraform_service_account = var.terraform_service_account
  requirements_filename     = "${path.module}/requirements.txt"

  module_depends_on = [
    time_sleep.wait_90_seconds_for_vpc_sc_propagation
  ]
}

resource "google_artifact_registry_repository_iam_member" "python-registry-iam" {
  provider = google-beta

  project    = var.project_id
  location   = var.location
  repository = local.python_repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.data_ingestion.dataflow_controller_service_account_email}"

  depends_on = [
    module.python_module_repository
  ]
}

resource "google_dataflow_flex_template_job" "flex_job" {
  provider = google-beta

  project                 = var.project_id
  name                    = "dataflow-flex-regional-dlp-job"
  container_spec_gcs_path = module.flex_dlp_template.flex_template_gs_path
  region                  = var.location

  parameters = {
    input_topic                    = "projects/${var.project_id}/topics/${module.data_ingestion.data_ingest_topic_name}"
    deidentification_template_name = "projects/${var.project_id}/locations/${var.location}/deidentifyTemplates/${module.de_identification_template_example.template_id}"
    dlp_location                   = var.location
    dlp_project                    = var.project_id
    bq_schema                      = local.bq_schema
    output_table                   = "${var.project_id}:${module.data_ingestion.data_ingest_bigquery_dataset.dataset_id}.classical_books"
    service_account_email          = module.data_ingestion.dataflow_controller_service_account_email
    subnetwork                     = module.data_ingestion.subnets_self_links[0]
    no_use_public_ips              = "true"
  }

  depends_on = [
    time_sleep.wait_90_seconds_for_vpc_sc_propagation,
    module.de_identification_template_example,
    module.flex_dlp_template,
    module.python_module_repository
  ]
}
