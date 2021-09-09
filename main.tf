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
  projects_ids  = [var.project_id, var.data_governance_project_id]
}

module "data_ingestion" {
  source                              = "./modules/base-data-ingestion"
  dataset_default_table_expiration_ms = var.dataset_default_table_expiration_ms
  bucket_name                         = var.bucket_name
  bucket_class                        = var.bucket_class
  bucket_lifecycle_rules              = var.bucket_lifecycle_rules
  dataset_id                          = var.dataset_id
  dataset_name                        = var.dataset_name
  dataset_description                 = var.dataset_description
  org_id                              = var.org_id
  project_id                          = var.project_id
  data_governance_project_id          = var.data_governance_project_id
  terraform_service_account           = var.terraform_service_account
  vpc_name                            = var.vpc_name
  access_context_manager_policy_id    = var.access_context_manager_policy_id
  perimeter_members                   = concat(["serviceAccount:${var.terraform_service_account}"], var.perimeter_additional_members)
  cmek_location                       = local.cmek_location
  region                              = local.region
  dataset_location                    = local.location
  bucket_location                     = local.location
  cmek_keyring_name                   = var.cmek_keyring_name
  subnet_ip                           = var.subnet_ip
}

module "centralized_logging" {
  source                  = "./modules/centralized-logging"
  count                   = var.enable_centralized_logging ? 1 : 0
  projects_ids            = local.projects_ids
  sink_filter             = var.sink_filter
  logging_project_id      = var.data_governance_project_id
  bucket_logging_prefix   = var.bucket_logging_prefix
  bucket_logging_location = local.location
  kms_key_name            = module.data_ingestion.cmek_ingestion_crypto_key
}

module "org_policies" {
  source             = "./modules/org_policies"
  for_each           = toset(local.projects_ids)
  project_id         = each.key
  region             = local.region
  trusted_subnetwork = module.data_ingestion.subnets_names[0]
  trusted_locations  = var.trusted_locations
}
