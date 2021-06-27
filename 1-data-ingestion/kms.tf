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
  storage_key  = "storage_crypto_key"
  bigquery_key = "bigquery_crypto_key"
  pubsub_key   = "pubsub_crypto_key"
  storage_sa   = data.google_storage_project_service_account.gcs_account.email_address
  pubsub_sa    = google_project_service_identity.pubsub_sa.email
  bigquery_sa  = data.google_bigquery_default_service_account.bigquery_sa.email
  keys         = [local.storage_key, local.bigquery_key, local.pubsub_key]

  sa_key_mapping = {
    (local.storage_key)  = local.storage_sa,
    (local.bigquery_key) = local.bigquery_sa,
    (local.pubsub_key)   = local.pubsub_sa
  }
}

data "google_storage_project_service_account" "gcs_account" {
  project = var.project_id
}

data "google_bigquery_default_service_account" "bigquery_sa" {
  project = var.project_id
}

resource "google_project_service_identity" "pubsub_sa" {
  provider = google-beta

  project = var.project_id
  service = "pubsub.googleapis.com"
}

module "cmek" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 2.0"

  project_id         = var.project_id
  location           = var.cmek_location
  keyring            = var.cmek_keyring_name
  prevent_destroy    = false
  keys               = local.keys
  set_encrypters_for = local.keys
  set_decrypters_for = local.keys

  encrypters = [
    "serviceAccount:${local.sa_key_mapping[local.keys[0]]}",
    "serviceAccount:${local.sa_key_mapping[local.keys[1]]}",
    "serviceAccount:${local.sa_key_mapping[local.keys[2]]}"
  ]

  decrypters = [
    "serviceAccount:${local.sa_key_mapping[local.keys[0]]}",
    "serviceAccount:${local.sa_key_mapping[local.keys[1]]}",
    "serviceAccount:${local.sa_key_mapping[local.keys[2]]}"
  ]
}
