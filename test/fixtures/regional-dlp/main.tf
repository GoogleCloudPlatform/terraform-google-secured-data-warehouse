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
  location     = "us-central1"
}

resource "random_id" "random_suffix" {
  byte_length = 4
}

module "kek" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 1.2"

  project_id      = var.data_governance_project_id[1]
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

module "regional_dlp_example" {
  source = "../../../examples/regional-dlp"

  org_id                            = var.org_id
  data_ingestion_project_id         = var.data_ingestion_project_id[1]
  data_governance_project_id        = var.data_governance_project_id[1]
  datalake_project_id               = var.datalake_project_id[1]
  privileged_data_project_id        = var.privileged_data_project_id[1]
  sdx_project_number                = var.sdx_project_number
  external_flex_template_project_id = var.external_flex_template_project_id
  location                          = local.location
  terraform_service_account         = var.terraform_service_account
  access_context_manager_policy_id  = var.access_context_manager_policy_id
  flex_template_gs_path             = var.python_de_identify_template_gs_path
  network_self_link                 = var.data_ingestion_network_self_link[1]
  subnetwork_self_link              = var.data_ingestion_subnets_self_link[1]
  delete_contents_on_destroy        = true
  perimeter_additional_members      = []

  crypto_key  = module.kek.keys[local.kek_key_name]
  wrapped_key = google_kms_secret_ciphertext.wrapped_key.ciphertext
}
