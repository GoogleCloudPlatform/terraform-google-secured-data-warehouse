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
  first_project_group  = "1"
  second_project_group = "2"
  third_project_group  = "3"
  project_groups = toset([
    local.first_project_group,
    local.second_project_group,
    local.third_project_group
  ])
}

# ====================== Examples to project groups mapping ===============================
# Examples "batch-data-ingestion" and "bigquery_sensitive_data" are together in one group.
# Examples "regional-dlp" and "simple_example" are together in one group.
# Examples "dataflow-with-dlp" and "de_identification_template" are together in one group.
# See "build/int.cloudbuild.yaml" file for the build of these groups linked by "waitFor:"
# =========================================================================================

resource "random_id" "project_id_suffix" {
  byte_length = 3
}

module "data_ingestion_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  for_each = local.project_groups

  name              = "ci-sdw-data-ing-${random_id.project_id_suffix.hex}"
  random_project_id = "true"
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

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
}

resource "google_app_engine_application" "app" {
  for_each = module.data_ingestion_project

  project     = each.value.project_id
  location_id = "us-central"
}

module "data_governance_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  for_each = local.project_groups

  name              = "ci-sdw-data-gov-${random_id.project_id_suffix.hex}"
  random_project_id = "true"
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

  activate_apis = [
    "datacatalog.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com",
    "dlp.googleapis.com"
  ]
}

module "datalake_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  for_each = local.project_groups

  name              = "ci-sdw-datalake-${random_id.project_id_suffix.hex}"
  random_project_id = "true"
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

  activate_apis = [
    "datacatalog.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "bigquery.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com",
    "dataflow.googleapis.com",
    "dlp.googleapis.com"
  ]
}

module "privileged_data_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  for_each = local.project_groups

  name              = "ci-sdw-privileged-${random_id.project_id_suffix.hex}"
  random_project_id = "true"
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

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
}

module "external_flex_template_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  name              = "ci-sdw-ext-flx-${random_id.project_id_suffix.hex}"
  random_project_id = "true"
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

  activate_apis = [
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com",
    "dlp.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "compute.googleapis.com"
  ]
}
