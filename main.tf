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
  region        = lower(var.region)
  location      = var.location == "" ? lower(var.region) : lower(var.location)
  cmek_location = local.location == "eu" ? "europe" : local.location

  projects_ids = {
    ingestion    = var.data_ingestion_project_id
    governance   = var.data_governance_project_id
    datalake     = var.datalake_project_id
    confidential = var.confidential_data_project_id
  }
}

module "data_governance" {
  source = "./modules/data-governance"

  terraform_service_account    = var.terraform_service_account
  data_ingestion_project_id    = var.data_ingestion_project_id
  data_governance_project_id   = var.data_governance_project_id
  confidential_data_project_id = var.confidential_data_project_id
  datalake_project_id          = var.datalake_project_id
  cmek_location                = local.cmek_location
  cmek_keyring_name            = var.cmek_keyring_name
  key_rotation_period_seconds  = var.key_rotation_period_seconds
  delete_contents_on_destroy   = var.delete_contents_on_destroy
}

module "data_ingestion" {
  source = "./modules/base-data-ingestion"

  dataset_default_table_expiration_ms = var.dataset_default_table_expiration_ms
  bucket_name                         = var.bucket_name
  bucket_class                        = var.bucket_class
  bucket_lifecycle_rules              = var.bucket_lifecycle_rules
  delete_contents_on_destroy          = var.delete_contents_on_destroy
  dataset_id                          = var.dataset_id
  dataset_name                        = var.dataset_name
  dataset_description                 = var.dataset_description
  org_id                              = var.org_id
  data_ingestion_project_id           = var.data_ingestion_project_id
  datalake_project_id                 = var.datalake_project_id
  data_governance_project_id          = var.data_governance_project_id
  terraform_service_account           = var.terraform_service_account
  region                              = local.region
  dataset_location                    = local.location
  bucket_location                     = local.location
  ingestion_encryption_key            = module.data_governance.cmek_ingestion_crypto_key
  bigquery_encryption_key             = module.data_governance.cmek_bigquery_crypto_key
}

module "bigquery_confidential_data" {
  source = "./modules/confidential-data"

  data_governance_project_id            = var.data_governance_project_id
  confidential_data_project_id          = var.confidential_data_project_id
  non_confidential_project_id           = var.datalake_project_id
  dataset_id                            = var.confidential_dataset_id
  location                              = local.location
  cmek_confidential_bigquery_crypto_key = module.data_governance.cmek_confidential_bigquery_crypto_key
  cmek_reidentification_crypto_key      = module.data_governance.cmek_reidentification_crypto_key
  delete_contents_on_destroy            = var.delete_contents_on_destroy
}

module "org_policies" {
  source   = "./modules/org-policies"
  for_each = local.projects_ids

  project_id        = each.value
  region            = local.region
  trusted_locations = var.trusted_locations

  depends_on = [
    module.data_ingestion,
    module.bigquery_confidential_data
  ]
}
