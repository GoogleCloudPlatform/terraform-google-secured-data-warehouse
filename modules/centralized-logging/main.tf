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

  new_bucket_name             = "${var.bucket_name}-${random_id.random_suffix.hex}"
  bucket_name                 = var.create_bucket ? module.logging_bucket[0].bucket.name : var.bucket_name
  destination_uri             = "storage.googleapis.com/${local.bucket_name}"
  storage_sa                  = data.google_storage_project_service_account.gcs_account.email_address
  logging_key_name            = "centralized_logging_kms_key_${random_id.random_suffix.hex}"
  keys                        = [local.logging_key_name]
  key_rotation_period_seconds = "2592000s"
  log_exports = toset([
    for value in module.log_export : value
  ])
  parent_resource_ids = [for parent_resource_id in local.log_exports[*].parent_resource_id : parent_resource_id]
}

resource "random_id" "random_suffix" {
  byte_length = 4
}

data "google_storage_project_service_account" "gcs_account" {
  project = var.logging_project_id
}

module "cmek" {
  count   = var.create_bucket ? 1 : 0
  source  = "terraform-google-modules/kms/google"
  version = "~> 2.0.1"

  project_id          = var.logging_project_id
  location            = var.logging_location
  keyring             = local.logging_key_name
  key_rotation_period = local.key_rotation_period_seconds
  keys                = local.keys
  set_encrypters_for  = local.keys
  set_decrypters_for  = local.keys
  encrypters          = ["serviceAccount:${local.storage_sa}"]
  decrypters          = ["serviceAccount:${local.storage_sa}"]
}

module "logging_bucket" {
  count   = var.create_bucket ? 1 : 0
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.1"

  name          = local.new_bucket_name
  project_id    = var.logging_project_id
  location      = var.logging_location
  force_destroy = true
  encryption = {
    default_kms_key_name = module.cmek[0].keys[local.logging_key_name]
  }
}

module "log_export" {
  for_each               = var.projects_ids
  source                 = "terraform-google-modules/log-export/google"
  version                = "~> 7.1.0"

  destination_uri        = local.destination_uri
  filter                 = var.sink_filter
  log_sink_name          = "sk-dwh-logging-bkt"
  parent_resource_id     = each.value
  parent_resource_type   = "project"
  unique_writer_identity = true
}

resource "google_storage_bucket_iam_member" "storage_sink_member" {
  for_each = module.log_export
  bucket   = local.bucket_name
  role     = "roles/storage.objectCreator"
  member   = each.value.writer_identity
}
