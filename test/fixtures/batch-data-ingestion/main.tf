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
  keyring  = "keyring_kek_${random_id.random_suffix.hex}"
  key_name = "key_name_kek_${random_id.random_suffix.hex}"
  region   = "us-central1"
}

data "google_service_account" "dataflow_service_account" {
  account_id = "sa-dataflow-controller"
  project    = var.project_id
}

data "google_compute_network" "vpc_network" {
  name    = "vpc-tst-network"
  project = var.project_id
}

resource "random_id" "random_suffix" {
  byte_length = 4
}

module "kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 1.2"

  project_id      = var.project_id
  location        = var.dlp_location
  keyring         = local.keyring
  keys            = [local.key_name]
  prevent_destroy = false
}

resource "random_id" "original_key" {
  byte_length = 16
}

resource "google_kms_secret_ciphertext" "wrapped_key" {
  crypto_key = module.kms.keys[local.key_name]
  plaintext  = random_id.original_key.b64_std
}

module "dataflow-with-dlp" {
  source                    = "../../../examples/batch-data-ingestion"
  project_id                = var.project_id
  crypto_key                = module.kms.keys[local.key_name]
  wrapped_key               = google_kms_secret_ciphertext.wrapped_key.ciphertext
  terraform_service_account = var.terraform_service_account
  dataflow_service_account  = data.google_service_account.dataflow_service_account.email
  network_self_link         = data.google_compute_network.vpc_network.id
  subnetwork_self_link      = data.google_compute_network.vpc_network.subnetworks_self_links[0]
  dataset_id                = "dts_test_data_ingestion"
  bucket_force_destroy      = true
}
