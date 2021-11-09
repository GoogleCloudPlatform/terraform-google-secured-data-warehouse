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
  kek_keyring                 = "kek_keyring_${random_id.suffix.hex}"
  kek_key_name                = "kek_key_${random_id.suffix.hex}"
  key_rotation_period_seconds = "2592000s" #30 days

  projects_ids = {
    data_ingestion   = module.base_projects.data_ingestion_project_id,
    governance       = module.base_projects.data_governance_project_id,
    non_confidential = module.base_projects.non_confidential_data_project_id,
    confidential     = module.base_projects.confidential_data_project_id
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

  data_ingestion_project_id        = module.base_projects.data_ingestion_project_id
  non_confidential_data_project_id = module.base_projects.non_confidential_data_project_id
  data_governance_project_id       = module.base_projects.data_governance_project_id
  confidential_data_project_id     = module.base_projects.confidential_data_project_id
  service_account_email            = var.terraform_service_account
}

resource "time_sleep" "wait_60_seconds_projects" {
  create_duration = "60s"

  depends_on = [
    module.iam_projects
  ]
}

resource "null_resource" "remove_owner_role" {
  for_each = local.projects_ids

  provisioner "local-exec" {
    command = <<EOF
    gcloud projects remove-iam-policy-binding ${each.value} \
    --member="serviceAccount:${var.terraform_service_account}" \
    --role="roles/owner" \
    --impersonate-service-account=${var.terraform_service_account}
EOF
  }

  depends_on = [
    time_sleep.wait_60_seconds_projects
  ]
}

module "template_project" {
  source = "../../test//setup/template-project"

  org_id                = var.org_id
  folder_id             = var.folder_id
  billing_account       = var.billing_account
  location              = local.location
  service_account_email = var.terraform_service_account
}

resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"

  depends_on = [
    module.template_project
  ]
}

resource "null_resource" "remove_owner_role_from_template" {
  provisioner "local-exec" {
    command = <<EOF
    gcloud projects remove-iam-policy-binding ${module.template_project.project_id} \
    --member="serviceAccount:${var.terraform_service_account}" \
    --role="roles/owner" \
    --impersonate-service-account=${var.terraform_service_account}
EOF
  }

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}

module "kek" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 1.2"

  project_id           = module.base_projects.data_governance_project_id
  location             = local.location
  keyring              = local.kek_keyring
  key_rotation_period  = local.key_rotation_period_seconds
  keys                 = [local.kek_key_name]
  key_protection_level = var.kms_key_protection_level
  prevent_destroy      = !var.delete_contents_on_destroy
}

resource "random_id" "original_key" {
  byte_length = 16
}

// TODO: Replace with a method that does not store the plain value in the state
resource "google_kms_secret_ciphertext" "wrapped_key" {
  crypto_key = module.kek.keys[local.kek_key_name]
  plaintext  = random_id.original_key.b64_std
}

module "centralized_logging" {
  source                      = "../../modules/centralized-logging"
  projects_ids                = local.projects_ids
  logging_project_id          = module.base_projects.data_governance_project_id
  kms_project_id              = module.base_projects.data_governance_project_id
  bucket_name                 = "bkt-logging-${module.base_projects.data_governance_project_id}"
  logging_location            = local.location
  delete_contents_on_destroy  = var.delete_contents_on_destroy
  key_rotation_period_seconds = local.key_rotation_period_seconds

  depends_on = [
    module.iam_projects
  ]
}
