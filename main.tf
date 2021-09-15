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
  region        = lower(var.region)
  location      = var.location == "" ? lower(var.region) : lower(var.location)
  cmek_location = local.location == "eu" ? "europe" : local.location

  projects_ids = [
    var.data_ingestion_project_id,
    var.data_governance_project_id,
    var.datalake_project_id,
    var.privileged_data_project_id
  ]
}

// A1 - DATA WAREHOUSE NETWORK - START

module "dwh_networking" {
  source = ".//modules/dwh-networking"

  # org_id     = var.org_id
  project_id = var.data_ingestion_project_id
  region     = var.region
  vpc_name   = var.vpc_name
  subnet_ip  = var.subnet_ip
}

module "dwh_networking_privileged" {
  source = ".//modules/dwh-networking"

  # org_id     = var.org_id
  project_id = var.privileged_data_project_id
  region     = var.region
  vpc_name   = var.vpc_name
  subnet_ip  = var.subnet_ip
}

// A1 - DATA WAREHOUSE NETWORK - END



// A2 - DATA WAREHOUSE GOVERNANCE - START

module "data_governance" {
  source = "./modules/data_governance"

  terraform_service_account   = var.terraform_service_account
  data_ingestion_project_id   = var.data_ingestion_project_id
  data_governance_project_id  = var.data_governance_project_id
  privileged_data_project_id  = var.privileged_data_project_id
  datalake_project_id         = var.datalake_project_id
  cmek_location               = local.cmek_location
  cmek_keyring_name           = var.cmek_keyring_name
  key_rotation_period_seconds = var.key_rotation_period_seconds
  delete_contents_on_destroy  = var.delete_contents_on_destroy
}

// A2 - DATA WAREHOUSE GOVERNANCE - END



// A3 - DATA WAREHOUSE INGESTION - START

module "data_ingestion" {
  source = "./modules/base-data-ingestion"

  dataset_default_table_expiration_ms = var.dataset_default_table_expiration_ms
  bucket_name                         = var.bucket_name
  bucket_class                        = var.bucket_class
  bucket_lifecycle_rules              = var.bucket_lifecycle_rules
  delete_contents_on_destroy          = var.delete_contents_on_destroy
  dataset_id                          = var.dataset_id
  dataset_name                        = var.dataset_name
  dataset_description                 = var.dataset_description
  org_id                              = var.org_id
  data_ingestion_project_id           = var.data_ingestion_project_id
  datalake_project_id                 = var.datalake_project_id
  data_governance_project_id          = var.data_governance_project_id
  terraform_service_account           = var.terraform_service_account
  region                              = local.region
  dataset_location                    = local.location
  bucket_location                     = local.location
  ingestion_encryption_key            = module.data_governance.cmek_ingestion_crypto_key
  bigquery_encryption_key             = module.data_governance.cmek_bigquery_crypto_key
}

// A3 - DATA WAREHOUSE INGESTION - END



// A4 - DATA WAREHOUSE SENSITIVE DATA - START

module "bigquery_sensitive_data" {
  source = "./modules/data_warehouse_taxonomy"

  taxonomy_project_id                   = var.data_governance_project_id
  privileged_data_project_id            = var.privileged_data_project_id
  non_sensitive_project_id              = var.datalake_project_id
  taxonomy_name                         = var.taxonomy_name
  table_id                              = var.confidential_table_id
  dataset_id                            = var.confidential_dataset_id
  location                              = local.location
  cmek_confidential_bigquery_crypto_key = module.data_governance.cmek_confidential_bigquery_crypto_key
  delete_contents_on_destroy            = var.delete_contents_on_destroy
}

// A4 - DATA WAREHOUSE SENSITIVE DATA - END



// A5 - DATA WAREHOUSE ORG POLICY - START

module "org_policies" {
  source = "./modules/org_policies"

  for_each           = toset(local.projects_ids)
  project_id         = each.key
  region             = local.region
  trusted_subnetwork = module.dwh_networking.subnets_names[0]
  trusted_locations  = var.trusted_locations
}

// A5 - DATA WAREHOUSE ORG POLICY - END




// A6 - DATA WAREHOUSE LOGGING - STAR

// A6 - DATA WAREHOUSE LOGGING - END



// A7 - DATA WAREHOUSE VPC-SC - START

locals {
  perimeter_members = distinct(concat([
    "serviceAccount:${module.data_ingestion.dataflow_controller_service_account_email}",
    "serviceAccount:${module.data_ingestion.storage_writer_service_account_email}",
    "serviceAccount:${module.data_ingestion.pubsub_writer_service_account_email}",
    "serviceAccount:${google_project_service_identity.cloudbuild_sa.email}",
    "serviceAccount:${var.terraform_service_account}"
  ], var.perimeter_additional_members))
}

resource "google_project_service_identity" "cloudbuild_sa" {
  provider = google-beta

  project = var.data_ingestion_project_id
  service = "cloudbuild.googleapis.com"
}

data "google_project" "ingestion_project" {
  project_id = var.data_ingestion_project_id
}

data "google_project" "governance_project" {
  project_id = var.data_governance_project_id
}

data "google_project" "datalake_project" {
  project_id = var.datalake_project_id
}

data "google_project" "privileged_project" {
  project_id = var.privileged_data_project_id
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "null_resource" "forces_wait_propagation" {
  provisioner "local-exec" {
    command = "echo \"\""
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sleep 240;"
  }

  depends_on = [
    module.data_ingestion,
    module.org_policies,
    module.dwh_networking,
    module.dwh_networking_privileged,
    module.data_governance
  ]
}

module "data_ingestion_vpc_sc" {
  source = ".//modules/dwh_vpc_sc"

  org_id                           = var.org_id
  project_id                       = var.data_ingestion_project_id
  access_context_manager_policy_id = var.access_context_manager_policy_id
  common_name                      = "data_ingestion"
  common_suffix                    = random_id.suffix.hex
  resources                        = [data.google_project.ingestion_project.number, data.google_project.datalake_project.number]
  perimeter_members                = local.perimeter_members
  restricted_services = [
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "dataflow.googleapis.com",
    "pubsub.googleapis.com",
    "cloudkms.googleapis.com",
    "dlp.googleapis.com",
    "compute.googleapis.com",
    "datacatalog.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudfunctions.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]

  # depends_on needed to prevent intermittent errors
  # when the VPC-SC is created but perimeter member
  # not yet propagated.
  depends_on = [
    null_resource.forces_wait_propagation
  ]
}

module "data_governance_vpc_sc" {
  source = ".//modules/dwh_vpc_sc"

  org_id                           = var.org_id
  project_id                       = var.data_governance_project_id
  access_context_manager_policy_id = var.access_context_manager_policy_id
  common_name                      = "data_governance"
  common_suffix                    = random_id.suffix.hex
  resources                        = [data.google_project.governance_project.number]
  perimeter_members                = local.perimeter_members
  restricted_services = [
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "dataflow.googleapis.com",
    "pubsub.googleapis.com",
    "cloudkms.googleapis.com",
    "dlp.googleapis.com",
    "compute.googleapis.com",
    "datacatalog.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudfunctions.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]

  # depends_on needed to prevent intermittent errors
  # when the VPC-SC is created but perimeter member
  # not yet propagated.
  depends_on = [
    null_resource.forces_wait_propagation
  ]
}

module "privileged_data_vpc_sc" {
  source = ".//modules/dwh_vpc_sc"

  org_id                           = var.org_id
  project_id                       = var.privileged_data_project_id
  access_context_manager_policy_id = var.access_context_manager_policy_id
  common_name                      = "privileged_data"
  common_suffix                    = random_id.suffix.hex
  resources                        = [data.google_project.privileged_project.number]
  perimeter_members                = local.perimeter_members
  restricted_services = [
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "dataflow.googleapis.com",
    "pubsub.googleapis.com",
    "cloudkms.googleapis.com",
    "dlp.googleapis.com",
    "compute.googleapis.com",
    "datacatalog.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudfunctions.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]

  # depends_on needed to prevent intermittent errors
  # when the VPC-SC is created but perimeter member
  # not yet propagated.
  depends_on = [
    null_resource.forces_wait_propagation
  ]
}

module "vpc_sc_bridge_ingestion_governance" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/bridge_service_perimeter"
  version = "~> 3.0"

  policy         = var.access_context_manager_policy_id
  perimeter_name = "vpc_sc_bridge_ingestion_governance_${random_id.suffix.hex}"
  description    = "VPC-SC bridge between data ingestion and data governance"

  resources = [
    data.google_project.ingestion_project.number,
    data.google_project.governance_project.number,
    data.google_project.datalake_project.number
  ]

  depends_on = [
    null_resource.forces_wait_propagation,
    module.data_governance_vpc_sc,
    module.data_ingestion_vpc_sc
  ]
}

module "vpc_sc_bridge_privileged_governance" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/bridge_service_perimeter"
  version = "~> 3.0"

  policy         = var.access_context_manager_policy_id
  perimeter_name = "vpc_sc_bridge_privileged_governance_${random_id.suffix.hex}"
  description    = "VPC-SC bridge between privileged data and data governance"

  resources = [
    data.google_project.privileged_project.number,
    data.google_project.governance_project.number
  ]

  depends_on = [
    null_resource.forces_wait_propagation,
    module.privileged_data_vpc_sc,
    module.data_governance_vpc_sc
  ]
}

module "vpc_sc_bridge_privileged_ingestion" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/bridge_service_perimeter"
  version = "~> 3.0"

  policy         = var.access_context_manager_policy_id
  perimeter_name = "vpc_sc_bridge_privileged_ingestion_${random_id.suffix.hex}"
  description    = "VPC-SC bridge between privileged data and data ingestion"

  resources = [
    data.google_project.privileged_project.number,
    data.google_project.datalake_project.number
  ]

  depends_on = [
    null_resource.forces_wait_propagation,
    module.privileged_data_vpc_sc,
    module.data_ingestion_vpc_sc
  ]
}

resource "time_sleep" "wait_for_bridge_propagation" {
  create_duration = "240s"

  depends_on = [
    module.vpc_sc_bridge_privileged_ingestion,
    module.vpc_sc_bridge_privileged_governance,
    module.vpc_sc_bridge_ingestion_governance
  ]
}

// A7 - DATA WAREHOUSE VPC-SC - END
