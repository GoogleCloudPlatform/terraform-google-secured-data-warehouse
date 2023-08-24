/**
    * Copyright 2023 Google LLC
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

module "data_governance_project" {
  source = "../single_project"
  count  = var.enable_sdw ? 1 : 0

  org_id          = local.org_id
  billing_account = local.billing_account
  folder_id       = local.env_folder_name
  environment     = var.env
  project_budget  = var.project_budget
  project_prefix  = local.project_prefix

  enable_cloudbuild_deploy            = local.enable_cloudbuild_deploy
  app_infra_pipeline_service_accounts = local.app_infra_pipeline_service_accounts

  sa_roles = {
    "${var.business_code}-sdw-app" = [
      "roles/bigquery.jobUser",
      "roles/cloudkms.admin",
      "roles/storage.admin",
      "roles/dlp.user",
      "roles/bigquery.admin",
      "roles/serviceusage.serviceUsageAdmin",
      "roles/dlp.inspectTemplatesEditor",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.serviceAccountUser",
      "roles/secretmanager.admin",
      "roles/datacatalog.admin",
      "roles/cloudkms.cryptoOperator",
      "roles/dlp.deidentifyTemplatesEditor"
    ]
  }

  activate_apis = [
    "cloudbuild.googleapis.com",
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
    "bigquery.googleapis.com",
  ]

  # Metadata
  project_suffix    = "data-gov"
  application_name  = "${var.business_code}-data-gov"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = var.business_code
}

module "confidential_data_project" {
  source = "../single_project"
  count  = var.enable_sdw ? 1 : 0

  org_id          = local.org_id
  billing_account = local.billing_account
  folder_id       = local.env_folder_name
  environment     = var.env
  project_budget  = var.project_budget
  project_prefix  = local.project_prefix

  vpc_type                   = "restricted"
  shared_vpc_host_project_id = local.restricted_host_project_id
  shared_vpc_subnets         = local.restricted_subnets_self_links

  enable_cloudbuild_deploy            = local.enable_cloudbuild_deploy
  app_infra_pipeline_service_accounts = local.app_infra_pipeline_service_accounts

  sa_roles = {
    "${var.business_code}-sdw-app" = [
      "roles/bigquery.jobUser",
      "roles/cloudkms.admin",
      "roles/storage.admin",
      "roles/dlp.user",
      "roles/bigquery.admin",
      "roles/serviceusage.serviceUsageAdmin",
      "roles/dlp.inspectTemplatesEditor",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.serviceAccountUser",
      "roles/dataflow.developer",
      "roles/resourcemanager.projectIamAdmin"
    ]
  }

  activate_apis = [
    "cloudbuild.googleapis.com",
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
    "bigquery.googleapis.com",
    "dataflow.googleapis.com",
    "dns.googleapis.com"
  ]

  # Metadata
  project_suffix    = "conf-data"
  application_name  = "${var.business_code}-conf-data"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = var.business_code
}

module "dwh_networking_confidential" {
  source = "git::https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse.git//modules/dwh-networking?ref=release-please--branches--main"
  # source  = "GoogleCloudPlatform/secured-data-warehouse/google//modules/dwh-networking"
  # version = "~> 1.0"

  count  = var.enable_sdw ? 1 : 0

  project_id = module.confidential_data_project[0].project_id
  region     = local.location
  vpc_name   = "reidentify"
  subnet_ip  = "10.0.32.0/21"
}

module "non_confidential_data_project" {
  source = "../single_project"
  count  = var.enable_sdw ? 1 : 0

  org_id                     = local.org_id
  billing_account            = local.billing_account
  folder_id                  = local.env_folder_name
  environment                = var.env
  project_budget             = var.project_budget
  project_prefix             = local.project_prefix

  vpc_type                   = "restricted"
  shared_vpc_host_project_id = local.restricted_host_project_id
  shared_vpc_subnets         = local.restricted_subnets_self_links

  enable_cloudbuild_deploy            = local.enable_cloudbuild_deploy
  app_infra_pipeline_service_accounts = local.app_infra_pipeline_service_accounts

  sa_roles = {
    "${var.business_code}-sdw-app" = [
      "roles/bigquery.jobUser",
      "roles/storage.admin",
      "roles/dlp.user",
      "roles/bigquery.admin",
      "roles/serviceusage.serviceUsageAdmin",
      "roles/dlp.inspectTemplatesEditor",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.serviceAccountUser",
      "roles/dataflow.developer"
    ]
  }

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

  vpc_service_control_attach_enabled = "false"
  vpc_service_control_perimeter_name = "accessPolicies/${local.access_context_manager_policy_id}/servicePerimeters/${local.perimeter_name}"
  vpc_service_control_sleep_duration = "60s"

  # Metadata
  project_suffix    = "non-conf-data"
  application_name  = "${var.business_code}-non-conf-data"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = var.business_code
}

module "data_ingestion_project" {
  source = "../single_project"
  count  = var.enable_sdw ? 1 : 0

  org_id                     = local.org_id
  billing_account            = local.billing_account
  folder_id                  = local.env_folder_name
  environment                = var.env
  vpc_type                   = "restricted"
  shared_vpc_host_project_id = local.restricted_host_project_id
  shared_vpc_subnets         = local.restricted_subnets_self_links
  project_budget             = var.project_budget
  project_prefix             = local.project_prefix

  enable_cloudbuild_deploy            = local.enable_cloudbuild_deploy
  app_infra_pipeline_service_accounts = local.app_infra_pipeline_service_accounts

  sa_roles = {
    "${var.business_code}-sdw-app" = [
      "roles/bigquery.jobUser",
      "roles/storage.admin",
      "roles/dlp.user",
      "roles/bigquery.admin",
      "roles/serviceusage.serviceUsageAdmin",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.serviceAccountUser",
      "roles/resourcemanager.projectIamAdmin",
      "roles/pubsub.admin",
      "roles/dataflow.developer"
    ]
  }

  activate_apis = [
    "accesscontextmanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "dns.googleapis.com",
    "bigquery.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com",
    "dataflow.googleapis.com",
    "dlp.googleapis.com",
    "appengine.googleapis.com",
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
  ]

  vpc_service_control_attach_enabled = "false"
  vpc_service_control_perimeter_name = "accessPolicies/${local.access_context_manager_policy_id}/servicePerimeters/${local.perimeter_name}"
  vpc_service_control_sleep_duration = "60s"

  # Metadata
  project_suffix    = "data-ing"
  application_name  = "${var.business_code}-data-ing"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = var.business_code
}

module "dataflow_template_project" {
  source = "../single_project"
  count  = var.enable_sdw ? 1 : 0

  org_id          = local.org_id
  billing_account = local.billing_account
  folder_id       = local.env_folder_name
  environment     = var.env
  project_budget  = var.project_budget
  project_prefix  = local.project_prefix

  enable_cloudbuild_deploy            = local.enable_cloudbuild_deploy
  app_infra_pipeline_service_accounts = local.app_infra_pipeline_service_accounts

  sa_roles = {
    "${var.business_code}-sdw-app" = [
      "roles/storage.admin",
      "roles/storage.objectCreator",
      "roles/browser",
      "roles/artifactregistry.admin",
      "roles/iam.serviceAccountCreator",
      "roles/iam.serviceAccountDeleter",
      "roles/cloudbuild.builds.editor"
    ]
  }

  activate_apis = [
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "cloudbilling.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "compute.googleapis.com",
  ]

  # Metadata
  project_suffix    = "dataflow"
  application_name  = "${var.business_code}-dataflow"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = var.business_code
}

resource "google_project_iam_member" "iam_admin" {
  count = var.enable_sdw ? 1 : 0

  project = module.data_ingestion_project[0].project_id
  role    = "roles/vpcaccess.admin"
  member  = "serviceAccount:${data.terraform_remote_state.bootstrap.outputs.networks_step_terraform_service_account_email}"
}
