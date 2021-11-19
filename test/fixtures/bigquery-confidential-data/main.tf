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
  kek_keyring                 = "kek_keyring_${random_id.random_suffix.hex}"
  kek_key_name                = "kek_key_${random_id.random_suffix.hex}"
  location                    = "us-east4"
  key_rotation_period_seconds = "2592000s"
  dlp_transformation_type     = "RE-IDENTIFY"
}

resource "random_id" "random_suffix" {
  byte_length = 4
}

module "kek" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 1.2"

  project_id           = var.data_governance_project_id[2]
  location             = local.location
  keyring              = local.kek_keyring
  keys                 = [local.kek_key_name]
  key_protection_level = "HSM"
  key_rotation_period  = local.key_rotation_period_seconds
  prevent_destroy      = false
}

resource "random_id" "original_key" {
  byte_length = 16
}

resource "google_kms_secret_ciphertext" "wrapped_key" {
  crypto_key = module.kek.keys[local.kek_key_name]
  plaintext  = random_id.original_key.b64_std
}

module "bigquery_confidential_data" {
  source = "../../..//examples/bigquery-confidential-data"

  org_id                            = var.org_id
  access_context_manager_policy_id  = var.access_context_manager_policy_id
  non_confidential_data_project_id  = var.non_confidential_data_project_id[2]
  data_ingestion_project_id         = var.data_ingestion_project_id[2]
  data_governance_project_id        = var.data_governance_project_id[2]
  confidential_data_project_id      = var.confidential_data_project_id[2]
  sdx_project_number                = var.sdx_project_number
  external_flex_template_project_id = var.external_flex_template_project_id
  crypto_key                        = module.kek.keys[local.kek_key_name]
  wrapped_key                       = google_kms_secret_ciphertext.wrapped_key.ciphertext
  terraform_service_account         = var.terraform_service_account
  java_de_identify_template_gs_path = var.java_de_identify_template_gs_path
  java_re_identify_template_gs_path = var.java_re_identify_template_gs_path
  data_ingestion_subnets_self_link  = var.data_ingestion_subnets_self_link[2]
  confidential_subnets_self_link    = var.confidential_subnets_self_link[2]
  delete_contents_on_destroy        = true
  perimeter_additional_members      = []
  dlp_transformation_type           = local.dlp_transformation_type
}
