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
  kek_keyring  = "kek_keyring_${random_id.random_suffix.hex}"
  kek_key_name = "kek_key_${random_id.random_suffix.hex}"
  location     = "us-east1"
}

resource "random_id" "random_suffix" {
  byte_length = 4
}

module "kek" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 1.2"

  project_id      = var.data_governance_project_id
  location        = local.location
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

module "test_vpc_module" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 3.2.0"
  project_id   = var.privileged_data_project_id
  network_name = "sdw-test-network"
  mtu          = 1460

  subnets = [
    {
      subnet_name   = "sdw-subnet-01"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = "us-east1"
    }
  ]
}

module "bigquery_sensitive_data" {
  source                     = "../../..//examples/bigquery_sensitive_data"
  non_sensitive_project_id   = var.datalake_project_id
  taxonomy_project_id        = var.data_governance_project_id
  privileged_data_project_id = var.privileged_data_project_id
  subnetwork                 = module.test_vpc_module.subnets_self_links[0]
  crypto_key                 = module.kek.keys[local.kek_key_name]
  wrapped_key                = google_kms_secret_ciphertext.wrapped_key.ciphertext
  terraform_service_account  = var.terraform_service_account
}
