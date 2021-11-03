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
  storage_sa  = data.google_storage_project_service_account.gcs_account.email_address
  pubsub_sa   = google_project_service_identity.pubsub_sa.email
  dataflow_sa = google_project_service_identity.dataflow_sa.email
  compute_sa  = "service-${data.google_project.data_ingestion_project.number}@compute-system.iam.gserviceaccount.com"
  bigquery_sa = data.google_bigquery_default_service_account.bigquery_sa.email

  confidential_storage_sa  = data.google_storage_project_service_account.confidential_gcs_account.email_address
  confidential_dataflow_sa = google_project_service_identity.confidential_dataflow_sa.email
  confidential_compute_sa  = "service-${data.google_project.reid_project.number}@compute-system.iam.gserviceaccount.com"
  confidential_bigquery_sa = data.google_bigquery_default_service_account.confidential_bigquery_sa.email

  data_ingestion_key_name = "data_ingestion_kms_key_${random_id.suffix.hex}"
  bigquery_key_name       = "bigquery_kms_key_${random_id.suffix.hex}"

  reidentification_key_name      = "reidentification_kms_key_${random_id.suffix.hex}"
  confidential_bigquery_key_name = "confidential_bigquery_kms_key_${random_id.suffix.hex}"

  data_ingestion_key_encrypters_decrypters = "serviceAccount:${local.storage_sa},serviceAccount:${local.pubsub_sa},serviceAccount:${local.dataflow_sa},serviceAccount:${local.compute_sa}"
  bigquery_key_encrypters_decrypters       = "serviceAccount:${local.bigquery_sa}"

  reidentification_key_encrypters_decrypters      = "serviceAccount:${local.confidential_storage_sa},serviceAccount:${local.confidential_dataflow_sa},serviceAccount:${local.confidential_compute_sa}"
  confidential_bigquery_key_encrypters_decrypters = "serviceAccount:${local.confidential_bigquery_sa}"


  keys = [
    local.data_ingestion_key_name,
    local.bigquery_key_name,
    local.reidentification_key_name,
    local.confidential_bigquery_key_name
  ]

  encrypters = [
    local.data_ingestion_key_encrypters_decrypters,
    local.bigquery_key_encrypters_decrypters,
    local.reidentification_key_encrypters_decrypters,
    local.confidential_bigquery_key_encrypters_decrypters
  ]

  decrypters = [
    local.data_ingestion_key_encrypters_decrypters,
    local.bigquery_key_encrypters_decrypters,
    local.reidentification_key_encrypters_decrypters,
    local.confidential_bigquery_key_encrypters_decrypters
  ]
}

resource "random_id" "suffix" {
  byte_length = 4
}

data "google_project" "data_ingestion_project" {
  project_id = var.data_ingestion_project_id
}

data "google_project" "governance_project" {
  project_id = var.data_governance_project_id
}

data "google_project" "non_confidential_data_project" {
  project_id = var.non_confidential_data_project_id
}

data "google_storage_project_service_account" "gcs_account" {
  project = var.data_ingestion_project_id
}

data "google_bigquery_default_service_account" "bigquery_sa" {
  project = var.non_confidential_data_project_id
}

resource "google_project_service_identity" "pubsub_sa" {
  provider = google-beta

  project = var.data_ingestion_project_id
  service = "pubsub.googleapis.com"
}

resource "google_project_service_identity" "dataflow_sa" {
  provider = google-beta

  project = var.data_ingestion_project_id
  service = "dataflow.googleapis.com"
}

data "google_project" "reid_project" {
  project_id = var.confidential_data_project_id
}

data "google_storage_project_service_account" "confidential_gcs_account" {
  project = var.confidential_data_project_id
}

data "google_bigquery_default_service_account" "confidential_bigquery_sa" {
  project = var.confidential_data_project_id
}

resource "google_project_service_identity" "confidential_dataflow_sa" {
  provider = google-beta

  project = var.confidential_data_project_id
  service = "dataflow.googleapis.com"
}

module "cmek" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 2.0.1"

  project_id           = var.data_governance_project_id
  location             = var.cmek_location
  keyring              = var.cmek_keyring_name
  key_rotation_period  = var.key_rotation_period_seconds
  prevent_destroy      = !var.delete_contents_on_destroy
  keys                 = local.keys
  key_protection_level = "HSM"
  set_encrypters_for   = local.keys
  set_decrypters_for   = local.keys
  encrypters           = local.encrypters
  decrypters           = local.decrypters
}
