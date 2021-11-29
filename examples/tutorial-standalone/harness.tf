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
  secret_name                 = "wrapped_key"
  wrapped_key_secret_data     = chomp(data.google_secret_manager_secret_version.wrapped_key.secret_data)

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


resource "google_project_iam_binding" "remove_owner_role" {
  for_each = local.projects_ids

  project = each.value
  role    = "roles/owner"
  members = []

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

resource "google_project_iam_binding" "remove_owner_role_from_template" {
  project = module.template_project.project_id
  role    = "roles/owner"
  members = []

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}

module "tek_wrapping_key" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 1.2"

  project_id           = module.base_projects.data_governance_project_id
  location             = local.location
  keyring              = local.kek_keyring
  key_rotation_period  = local.key_rotation_period_seconds
  keys                 = [local.kek_key_name]
  key_protection_level = "HSM"
  prevent_destroy      = !var.delete_contents_on_destroy
}

resource "google_secret_manager_secret" "wrapped_key_secret" {
  provider = google-beta

  secret_id = local.secret_name
  project   = module.base_projects.data_governance_project_id

  replication {
    user_managed {
      replicas {
        location = local.location
      }
    }
  }
}

resource "null_resource" "wrapped_key" {

  triggers = {
    secret_id = google_secret_manager_secret.wrapped_key_secret.id
  }

  provisioner "local-exec" {
    command = <<EOF
    ${path.module}/../../helpers/wrapped_key.sh \
    ${module.base_projects.data_governance_project_id} \
    ${local.location} \
    ${var.terraform_service_account} \
    ${local.kek_keyring} \
    ${local.kek_key_name} \
    ${local.secret_name}
EOF
  }

  depends_on = [
    module.tek_wrapping_key,
    google_secret_manager_secret.wrapped_key_secret,
    google_project_iam_binding.remove_owner_role
  ]
}

data "google_secret_manager_secret_version" "wrapped_key" {
  project = module.base_projects.data_governance_project_id
  secret  = google_secret_manager_secret.wrapped_key_secret.id

  depends_on = [
    null_resource.wrapped_key
  ]
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
