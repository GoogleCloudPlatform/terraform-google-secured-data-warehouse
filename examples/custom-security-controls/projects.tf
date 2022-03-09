/**
 * Copyright 2022 Google LLC
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
    data_ingestion   = var.data_ingestion_project_id,
    governance       = var.data_governance_project_id,
    non_confidential = var.non_confidential_data_project_id,
    confidential     = var.confidential_data_project_id
  }
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

module "iam_projects" {
  source = "../../test//setup/iam-projects"

  data_ingestion_project_id        = var.data_ingestion_project_id
  non_confidential_data_project_id = var.non_confidential_data_project_id
  data_governance_project_id       = var.data_governance_project_id
  confidential_data_project_id     = var.confidential_data_project_id
  service_account_email            = var.terraform_service_account
}

module "data_ingestion_project_id" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  count = var.create_projects ? 1 : 0

  name                    = var.data_ingestion_project_id
  org_id                  = var.org_id
  folder_id               = var.folder_id
  billing_account         = var.billing_account
  default_service_account = "deprivilege"

  activate_apis = [
    "datacatalog.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "dns.googleapis.com",
    "pubsub.googleapis.com",
    "bigquery.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com",
    "dataflow.googleapis.com",
    "dlp.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudbuild.googleapis.com",
    "appengine.googleapis.com",
    "artifactregistry.googleapis.com",
    "compute.googleapis.com"
  ]

  depends_on = [
    module.iam_projects,
    google_project_iam_binding.remove_owner_role
  ]
}

module "data_governance_project_id" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  count = var.create_projects ? 1 : 0

  name                    = var.data_governance_project_id
  org_id                  = var.org_id
  folder_id               = var.folder_id
  billing_account         = var.billing_account
  default_service_account = "deprivilege"

  activate_apis = [
    "datacatalog.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com",
    "dlp.googleapis.com",
    "secretmanager.googleapis.com"
  ]

  depends_on = [
    module.iam_projects,
    google_project_iam_binding.remove_owner_role
  ]
}

module "confidential_data_project_id" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  count = var.create_projects ? 1 : 0

  name                    = var.confidential_data_project_id
  org_id                  = var.org_id
  folder_id               = var.folder_id
  billing_account         = var.billing_account
  default_service_account = "deprivilege"

  activate_apis = [
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "bigquery.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com"
  ]

  depends_on = [
    module.iam_projects,
    google_project_iam_binding.remove_owner_role
  ]
}

module "non_confidential_data_project_id" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  count = var.create_projects ? 1 : 0

  name                    = var.non_confidential_data_project_id
  org_id                  = var.org_id
  folder_id               = var.folder_id
  billing_account         = var.billing_account
  default_service_account = "deprivilege"

  activate_apis = [
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "bigquery.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com",
    "dataflow.googleapis.com",
    "dlp.googleapis.com",
    "datacatalog.googleapis.com",
    "dns.googleapis.com",
    "compute.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com"
  ]

  depends_on = [
    module.iam_projects,
    google_project_iam_binding.remove_owner_role
  ]
}
