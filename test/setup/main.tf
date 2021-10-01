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

# ====================== Examples to project groups mapping ================================================
# Examples "dataflow-with-dlp" and "batch-data-ingestion" are together in one group.
# Examples "simple_example" and "regional-dlp" are together in one group.
# Examples "bigquery_confidential_data" and "de_identification_template" are together in one group.
#
# To add a new example, add it to one of the groups and try keep the number of examples that
# deploy the main module to two in that group.
# If that is not possible, try to refactor one of the examples to include your new case.
# If that is not possible, follow these step to add a new group:
#  1) Create a new project group and add it to the "project_groups" local,
#  2) In "test/setup/iam.tf" create a new set of "google_project_iam_member" resources for the new group,
#  3) In your new test fixture use the projects from the new group like "var.data_ingestion_project_id[3]",
#  4) Update "build/int.cloudbuild.yaml" to create a new sequence of build steps for the new group. The
#     initial step of the new groups must "waitFor:" the "prepare" step.
#
# See "build/int.cloudbuild.yaml" file for the build of these groups linked by "waitFor:"
# ==========================================================================================================

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
  location_id = "us-east4"
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

module "confidential_data_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  for_each = local.project_groups

  name              = "ci-sdw-CONF-${random_id.project_id_suffix.hex}"
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
