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
  perimeter_members_ingestion = distinct(concat([
    "serviceAccount:${module.data_ingestion.dataflow_controller_service_account_email}",
    "serviceAccount:${module.data_ingestion.storage_writer_service_account_email}",
    "serviceAccount:${module.data_ingestion.pubsub_writer_service_account_email}",
    "serviceAccount:${google_project_service_identity.data_ingestion_cloudbuild_sa.email}",
    "serviceAccount:${var.terraform_service_account}"
  ], var.perimeter_additional_members))

  perimeter_members_governance = distinct(concat([
    "serviceAccount:${var.terraform_service_account}"
  ], var.perimeter_additional_members))

  perimeter_members_privileged = distinct(concat([
    "serviceAccount:${var.terraform_service_account}"
  ], var.perimeter_additional_members))
}

resource "google_project_service_identity" "data_ingestion_cloudbuild_sa" {
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

// It's necessary to use the forces_wait_propagation to guarantee the resources that use this VPC do not have issues related to the propagation.
// See: https://cloud.google.com/vpc-service-controls/docs/manage-service-perimeters#update.
resource "time_sleep" "forces_wait_propagation" {
  destroy_duration = "240s"

  depends_on = [
    module.data_ingestion,
    module.org_policies,
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
  perimeter_members                = local.perimeter_members_ingestion
  restricted_services = [
    "bigquery.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "datacatalog.googleapis.com",
    "dataflow.googleapis.com",
    "dlp.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "secretmanager.googleapis.com",
    "storage.googleapis.com"
  ]

  # depends_on needed to prevent intermittent errors
  # when the VPC-SC is created but perimeter member
  # not yet propagated.
  depends_on = [
    time_sleep.forces_wait_propagation
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
  perimeter_members                = local.perimeter_members_governance
  restricted_services = [
    "bigquery.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "datacatalog.googleapis.com",
    "dataflow.googleapis.com",
    "dlp.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "secretmanager.googleapis.com",
    "storage.googleapis.com"
  ]

  # depends_on needed to prevent intermittent errors
  # when the VPC-SC is created but perimeter member
  # not yet propagated.
  depends_on = [
    time_sleep.forces_wait_propagation
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
  perimeter_members                = local.perimeter_members_privileged
  restricted_services = [
    "bigquery.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "datacatalog.googleapis.com",
    "dataflow.googleapis.com",
    "dlp.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "secretmanager.googleapis.com",
    "storage.googleapis.com"
  ]

  # depends_on needed to prevent intermittent errors
  # when the VPC-SC is created but perimeter member
  # not yet propagated.
  depends_on = [
    time_sleep.forces_wait_propagation
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
    time_sleep.forces_wait_propagation,
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
    time_sleep.forces_wait_propagation,
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
    time_sleep.forces_wait_propagation,
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
