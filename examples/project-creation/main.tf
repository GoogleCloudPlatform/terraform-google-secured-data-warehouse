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

module "data_ingestion_project_id" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

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
}

module "data_governance_project_id" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

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
}

module "confidential_data_project_id" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

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
}

module "non_confidential_data_project_id" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

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
}

###

module "secured_data_warehouse" {
  source                           = "../.."
  org_id                           = var.org_id
  data_governance_project_id       = var.data_governance_project_id
  confidential_data_project_id     = var.confidential_data_project_id
  non_confidential_data_project_id = var.non_confidential_data_project_id
  data_ingestion_project_id        = var.data_ingestion_project_id
  sdx_project_number               = var.sdx_project_number
  terraform_service_account        = var.terraform_service_account
  access_context_manager_policy_id = var.access_context_manager_policy_id
  bucket_name                      = "bucket_simple_example"
  dataset_id                       = "dataset_simple_example"
  cmek_keyring_name                = "key_name_simple_example"
  pubsub_resource_location         = "us-east4"
  location                         = "us-east4"
  delete_contents_on_destroy       = var.delete_contents_on_destroy
  perimeter_additional_members     = var.perimeter_additional_members
  data_engineer_group              = var.data_engineer_group
  data_analyst_group               = var.data_analyst_group
  security_analyst_group           = var.security_analyst_group
  network_administrator_group      = var.network_administrator_group
  security_administrator_group     = var.security_administrator_group

  depends_on = [
    module.data_ingestion_project_id,
    module.data_governance_project_id,
    module.confidential_data_project_id,
    module.non_confidential_data_project_id
  ]
}
