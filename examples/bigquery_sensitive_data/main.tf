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
  location                = "us-central1"
  dataset_id              = "non_sensitive_dataset"
  confidential_dataset_id = "secured_dataset"
}
resource "random_id" "suffix" {
  byte_length = 4
}

module "secured_data_warehouse" {
  source                           = "../.."
  org_id                           = var.org_id
  taxonomy_name                    = "secured_taxonomy"
  data_governance_project_id       = var.data_governance_project_id
  privileged_data_project_id       = var.privileged_data_project_id
  datalake_project_id              = var.non_sensitive_project_id
  data_ingestion_project_id        = var.data_ingestion_project_id
  sdx_project_number               = var.sdx_project_number
  terraform_service_account        = var.terraform_service_account
  access_context_manager_policy_id = var.access_context_manager_policy_id
  bucket_name                      = "bkt-data-ingestion"
  location                         = local.location
  region                           = local.location
  dataset_id                       = local.dataset_id
  confidential_dataset_id          = local.confidential_dataset_id
  confidential_table_id            = "sample_data"
  cmek_keyring_name                = "cmek_keyring_${random_id.suffix.hex}"
  delete_contents_on_destroy       = var.delete_contents_on_destroy
}
