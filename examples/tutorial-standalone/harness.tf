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
  logging_key_name            = "centralized_logging_kms_key_${random_id.suffix.hex}"
  keys                        = [local.logging_key_name]
  key_rotation_period_seconds = "2592000s"

  projects_ids = {
    landing_zone     = module.base_projects.data_governance_project_id,
    governance       = module.base_projects.confidential_data_project_id,
    non_confidential = module.base_projects.datalake_project_id
    confidential     = module.base_projects.data_ingestion_project_id
  }
}

module "base_projects" {
  source = "../../test//setup/base-projects"

  org_id          = var.org_id
  folder_id       = var.folder_id
  billing_account = var.billing_account
  region          = local.location
}

module "iam_projects" {
  source = "../../test//setup/iam-projects"

  data_ingestion_project_id    = module.base_projects.data_ingestion_project_id
  datalake_project_id          = module.base_projects.datalake_project_id
  data_governance_project_id   = module.base_projects.data_governance_project_id
  confidential_data_project_id = module.base_projects.confidential_data_project_id
  service_account_email        = var.terraform_service_account
}

module "template_project" {
  source = "../../test//setup/template-project"

  org_id                = var.org_id
  folder_id             = var.folder_id
  billing_account       = var.billing_account
  location              = local.location
  service_account_email = var.terraform_service_account
}

module "cmek" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 2.0.1"

  project_id          = module.base_projects.data_governance_project_id
  location            = local.location
  keyring             = local.logging_key_name
  key_rotation_period = local.key_rotation_period_seconds
  keys                = local.keys
}

module "centralized_logging" {
  source                  = "../../modules/centralized-logging"
  projects_ids            = local.projects_ids
  logging_project_id      = module.base_projects.data_governance_project_id
  bucket_logging_prefix   = "bkt-logging-${module.base_projects.data_governance_project_id}"
  bucket_logging_location = local.location
  kms_key_name            = module.cmek.keys[local.logging_key_name]
}
