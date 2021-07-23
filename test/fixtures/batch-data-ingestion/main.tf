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
  region = "us-central1"
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

data "google_kms_key_ring" "kms" {
  name     = "${var.cmek_keyring_name}"
  location = var.cmek_location
  project  = var.project_id
}

data "google_kms_crypto_key" "crypto_key" {
  name     = "ingestion_kms_key"
  key_ring = data.google_kms_key_ring.kms.self_link
}

module "batch-dataflow" {
  source                    = "../../../examples/batch-data-ingestion"
  project_id                = var.project_id
  crypto_key                = data.google_kms_crypto_key.crypto_key.self_link
  terraform_service_account = var.terraform_service_account
  dataflow_service_account  = data.google_service_account.dataflow_service_account.email
  network_self_link         = data.google_compute_network.vpc_network.id
  subnetwork_self_link      = data.google_compute_network.vpc_network.subnetworks_self_links[0]
  dataset_id                = "dts_test_data_ingestion"
  bucket_force_destroy      = true
}
