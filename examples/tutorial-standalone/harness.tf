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

resource "null_resource" "remove_owner_role" {
  for_each = local.projects_ids

  provisioner "local-exec" {
    command = <<EOF
    gcloud projects remove-iam-policy-binding ${each.value} \
    --member="serviceAccount:${var.terraform_service_account}" --role="roles/owner"
EOF
  }

  depends_on = [
    module.iam_projects
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

resource "null_resource" "remove_owner_role_from_template" {
  provisioner "local-exec" {
    command = <<EOF
    gcloud projects remove-iam-policy-binding ${module.template_project.project_id} \
    --member="serviceAccount:${var.terraform_service_account}" --role="roles/owner"
EOF
  }

  depends_on = [
    module.template_project
  ]
}

module "centralized_logging" {
  source                     = "../../modules/centralized-logging"
  projects_ids               = local.projects_ids
  logging_project_id         = module.base_projects.data_governance_project_id
  bucket_name                = "bkt-logging-${module.base_projects.data_governance_project_id}"
  logging_location           = local.location
  delete_contents_on_destroy = var.delete_contents_on_destroy
}
