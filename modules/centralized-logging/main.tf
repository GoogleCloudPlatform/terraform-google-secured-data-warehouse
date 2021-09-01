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
  destination_uri = "storage.googleapis.com/${module.bucket.bucket.name}"
  storage_sa      = data.google_storage_project_service_account.gcs_account.email_address

  encrypters = [
    "serviceAccount:${local.storage_sa}"
  ]

  decrypters = [
    "serviceAccount:${local.storage_sa}"
  ]
}

data "google_storage_project_service_account" "gcs_account" {
  project = var.logging_project_id
}

resource "google_kms_crypto_key_iam_binding" "decrypters" {
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  crypto_key_id = var.kms_key_name
  members       = local.decrypters
}

resource "google_kms_crypto_key_iam_binding" "encrypters" {
  role          = "roles/cloudkms.cryptoKeyEncrypter"
  crypto_key_id = var.kms_key_name
  members       = local.encrypters
}

module "bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.1"

  name       = var.bucket_logging_name
  project_id = var.logging_project_id
  location   = var.bucket_logging_location

  encryption = {
    default_kms_key_name = var.kms_key_name
  }

  depends_on = [
    google_kms_crypto_key_iam_binding.decrypters,
    google_kms_crypto_key_iam_binding.encrypters
  ]
}

module "log_export" {
  for_each               = toset(var.projects_ids)
  source                 = "terraform-google-modules/log-export/google"
  version                = "~> 7.1.0"
  
  destination_uri        = local.destination_uri
  filter                 = var.sink_filter
  log_sink_name          = "${var.bucket_logging_name}_${each.key}_logsink"
  parent_resource_id     = each.key
  parent_resource_type   = "project"
  unique_writer_identity = true
}

resource "google_storage_bucket_iam_member" "storage_sink_member" {
  for_each = module.log_export
  bucket   = var.bucket_logging_name
  role     = "roles/storage.objectCreator"
  member   = "${each.value.writer_identity}"
}
