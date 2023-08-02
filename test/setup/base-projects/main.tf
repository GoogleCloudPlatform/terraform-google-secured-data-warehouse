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
  app_engine_location = lookup({ "europe-west1" = "europe-west", "us-central1" = "us-central" }, var.region, var.region)

  data_ingestion_project_name        = var.data_ingestion_project_name != "" ? var.data_ingestion_project_name : "sdw-data-ing-${random_id.project_id_suffix.hex}"
  data_governance_project_name       = var.data_governance_project_name != "" ? var.data_governance_project_name : "sdw-data-gov-${random_id.project_id_suffix.hex}"
  non_confidential_data_project_name = var.non_confidential_data_project_name != "" ? var.non_confidential_data_project_name : "sdw-non-conf-${random_id.project_id_suffix.hex}"
  confidential_data_project_name     = var.confidential_data_project_name != "" ? var.confidential_data_project_name : "sdw-conf-${random_id.project_id_suffix.hex}"


}

resource "random_id" "project_id_suffix" {
  byte_length = 3
}

module "data_ingestion_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  name                    = local.data_ingestion_project_name
  random_project_id       = "true"
  org_id                  = var.org_id
  labels                  = var.labels
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
    "compute.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

resource "google_app_engine_application" "app" {
  project     = module.data_ingestion_project.project_id
  location_id = local.app_engine_location
}

module "data_governance_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  name                    = local.data_governance_project_name
  random_project_id       = "true"
  org_id                  = var.org_id
  labels                  = var.labels
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
    "secretmanager.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]
}

module "non_confidential_data_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  name                    = local.non_confidential_data_project_name
  random_project_id       = "true"
  org_id                  = var.org_id
  labels                  = var.labels
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
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]
}


module "confidential_data_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  name                    = local.confidential_data_project_name
  random_project_id       = "true"
  org_id                  = var.org_id
  labels                  = var.labels
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
    "artifactregistry.googleapis.com",
    "monitoring.googleapis.com"
  ]
}
