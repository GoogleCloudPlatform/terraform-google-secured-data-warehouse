/**
 * Copyright 2021-2022 Google LLC
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
  new_bucket_name      = "${var.bucket_name}-${random_id.suffix.hex}"
  bucket_name          = var.create_bucket ? module.logging_bucket[0].resource_name : var.bucket_name
  destination_uri      = "storage.googleapis.com/${local.bucket_name}"
  storage_sa           = data.google_storage_project_service_account.gcs_account.email_address
  logging_keyring_name = "logging_keyring_${random_id.suffix.hex}"
  logging_key_name     = "logging_key"
  keys                 = [local.logging_key_name]
  enabling_data_logs   = var.data_access_logs_enabled ? ["DATA_WRITE", "DATA_READ"] : []
  parent_resource_ids  = [for parent_resource_id in local.log_exports[*].parent_resource_id : parent_resource_id]

  log_exports = toset([
    for value in module.log_export : value
  ])
}

resource "random_id" "suffix" {
  byte_length = 4
}

data "google_storage_project_service_account" "gcs_account" {
  project = var.logging_project_id
}

module "cmek" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 2.2"

  count = var.create_bucket ? 1 : 0

  project_id           = var.kms_project_id
  labels               = var.labels
  location             = var.logging_location
  keyring              = local.logging_keyring_name
  key_rotation_period  = var.key_rotation_period_seconds
  keys                 = local.keys
  key_protection_level = var.kms_key_protection_level
  set_encrypters_for   = local.keys
  set_decrypters_for   = local.keys
  encrypters           = ["serviceAccount:${local.storage_sa}"]
  decrypters           = ["serviceAccount:${local.storage_sa}"]
  prevent_destroy      = !var.delete_contents_on_destroy
}

module "logging_bucket" {
  source  = "terraform-google-modules/log-export/google//modules/storage"
  version = "~> 7.3.0"

  count                       = var.create_bucket ? 1 : 0
  project_id                  = var.logging_project_id
  storage_bucket_name         = local.new_bucket_name
  log_sink_writer_identity    = module.log_export[keys(var.projects_ids)[0]].writer_identity
  kms_key_name                = module.cmek[0].keys[local.logging_key_name]
  uniform_bucket_level_access = true
  force_destroy               = var.delete_contents_on_destroy
  lifecycle_rules             = var.lifecycle_rules
  retention_policy            = var.retention_policy
  location                    = var.logging_location
}

module "log_export" {
  source  = "terraform-google-modules/log-export/google"
  version = "~> 7.6"

  for_each = var.projects_ids

  destination_uri        = local.destination_uri
  filter                 = var.sink_filter
  log_sink_name          = "sk-dwh-logging-bkt"
  parent_resource_id     = each.value
  parent_resource_type   = "project"
  unique_writer_identity = true
}

resource "google_storage_bucket_iam_member" "storage_sink_member" {
  for_each = module.log_export

  bucket = local.bucket_name
  role   = "roles/storage.objectCreator"
  member = each.value.writer_identity
}

resource "google_project_iam_audit_config" "project_config" {
  for_each = var.projects_ids

  project = "projects/${each.value}"
  service = "allServices"

  ###################################################################################################
  ### Audit logs can generate costs, to know more about it,
  ### check the official documentation: https://cloud.google.com/stackdriver/pricing#logging-costs
  ### To know more about audit logs, you can find more infos
  ### here https://cloud.google.com/logging/docs/audit/configure-data-access
  ### To enable DATA_READ and DATA_WRITE audit logs, set `data_access_logs_enabled` to true
  ### ADMIN_READ logs are enabled by default.
  ####################################################################################################
  dynamic "audit_log_config" {
    for_each = setunion(local.enabling_data_logs, ["ADMIN_READ"])
    content {
      log_type = audit_log_config.key
    }
  }
}
