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
  perimeter_members_landing_zone = distinct(concat([
    "serviceAccount:${module.landing_zone.dataflow_controller_service_account_email}",
    "serviceAccount:${module.landing_zone.storage_writer_service_account_email}",
    "serviceAccount:${module.landing_zone.pubsub_writer_service_account_email}",
    "serviceAccount:${var.terraform_service_account}"
  ], var.perimeter_additional_members))

  perimeter_members_governance = distinct(concat([
    "serviceAccount:${var.terraform_service_account}"
  ], var.perimeter_additional_members))

  perimeter_members_confidential = distinct(concat([
    "serviceAccount:${var.terraform_service_account}"
  ], var.perimeter_additional_members))
}

data "google_project" "landing_zone_project" {
  project_id = var.landing_zone_project_id
}

data "google_project" "governance_project" {
  project_id = var.data_governance_project_id
}

data "google_project" "non_confidential_data_project" {
  project_id = var.non_confidential_data_project_id
}

data "google_project" "confidential_project" {
  project_id = var.confidential_data_project_id
}

resource "random_id" "suffix" {
  byte_length = 4
}

// It's necessary to use the forces_wait_propagation to guarantee the resources that use this VPC do not have issues related to the propagation.
// See: https://cloud.google.com/vpc-service-controls/docs/manage-service-perimeters#update.
resource "time_sleep" "forces_wait_propagation" {
  destroy_duration = "330s"

  depends_on = [
    module.landing_zone,
    module.org_policies,
    module.data_governance,
    module.bigquery_confidential_data
  ]
}

module "landing_zone_vpc_sc" {
  source = ".//modules/dwh-vpc-sc"

  org_id                           = var.org_id
  project_id                       = var.landing_zone_project_id
  access_context_manager_policy_id = var.access_context_manager_policy_id
  common_name                      = "landing_zone"
  common_suffix                    = random_id.suffix.hex
  resources                        = [data.google_project.landing_zone_project.number, data.google_project.non_confidential_data_project.number]
  perimeter_members                = local.perimeter_members_landing_zone
  restricted_services = [
    #"artifactregistry.googleapis.com",
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

  sdx_egress_rule = [
    {
      sdx_identities = distinct(concat(
        var.landing_zone_dataflow_deployer_identities,
        ["serviceAccount:${var.terraform_service_account}"]
      ))
      sdx_project_number = var.sdx_project_number
      service_name       = "storage.googleapis.com"
      method             = "google.storage.objects.get"
    },
    {
      sdx_identities     = ["serviceAccount:${module.landing_zone.dataflow_controller_service_account_email}"]
      sdx_project_number = var.sdx_project_number
      service_name       = "artifactregistry.googleapis.com"
      method             = "artifactregistry.googleapis.com/DockerRead"
    }
  ]

  # depends_on needed to prevent intermittent errors
  # when the VPC-SC is created but perimeter member
  # not yet propagated.
  depends_on = [
    time_sleep.forces_wait_propagation
  ]
}

module "data_governance_vpc_sc" {
  source = ".//modules/dwh-vpc-sc"

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

module "confidential_data_vpc_sc" {
  source = ".//modules/dwh-vpc-sc"

  org_id                           = var.org_id
  project_id                       = var.confidential_data_project_id
  access_context_manager_policy_id = var.access_context_manager_policy_id
  common_name                      = "confidential_data"
  common_suffix                    = random_id.suffix.hex
  resources                        = [data.google_project.confidential_project.number]
  perimeter_members                = local.perimeter_members_confidential
  restricted_services = [
    #"artifactregistry.googleapis.com",
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

  sdx_egress_rule = [
    {
      sdx_identities = distinct(concat(
        var.confidential_data_dataflow_deployer_identities,
        ["serviceAccount:${var.terraform_service_account}"]
      ))
      sdx_project_number = var.sdx_project_number
      service_name       = "storage.googleapis.com"
      method             = "google.storage.objects.get"
    },
    {
      sdx_identities     = ["serviceAccount:${module.bigquery_confidential_data.confidential_dataflow_controller_service_account_email}"]
      sdx_project_number = var.sdx_project_number
      service_name       = "artifactregistry.googleapis.com"
      method             = "artifactregistry.googleapis.com/DockerRead"
    }
  ]

  # depends_on needed to prevent intermittent errors
  # when the VPC-SC is created but perimeter member
  # not yet propagated.
  depends_on = [
    time_sleep.forces_wait_propagation
  ]
}

module "vpc_sc_bridge_landing_zone_governance" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/bridge_service_perimeter"
  version = "~> 3.0"

  policy         = var.access_context_manager_policy_id
  perimeter_name = "vpc_sc_bridge_landing_zone_governance_${random_id.suffix.hex}"
  description    = "VPC-SC bridge between landing zone and data governance"

  resources = [
    data.google_project.landing_zone_project.number,
    data.google_project.governance_project.number,
    data.google_project.non_confidential_data_project.number
  ]

  depends_on = [
    time_sleep.forces_wait_propagation,
    module.data_governance_vpc_sc,
    module.landing_zone_vpc_sc
  ]
}

module "vpc_sc_bridge_confidential_governance" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/bridge_service_perimeter"
  version = "~> 3.0"

  policy         = var.access_context_manager_policy_id
  perimeter_name = "vpc_sc_bridge_confidential_governance_${random_id.suffix.hex}"
  description    = "VPC-SC bridge between confidential data and data governance"

  resources = [
    data.google_project.confidential_project.number,
    data.google_project.governance_project.number
  ]

  depends_on = [
    time_sleep.forces_wait_propagation,
    module.confidential_data_vpc_sc,
    module.data_governance_vpc_sc
  ]
}

module "vpc_sc_bridge_confidential_landing_zone" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/bridge_service_perimeter"
  version = "~> 3.0"

  policy         = var.access_context_manager_policy_id
  perimeter_name = "vpc_sc_bridge_confidential_landing_zone_${random_id.suffix.hex}"
  description    = "VPC-SC bridge between confidential data and landing zone"

  resources = [
    data.google_project.confidential_project.number,
    data.google_project.non_confidential_data_project.number
  ]

  depends_on = [
    time_sleep.forces_wait_propagation,
    module.confidential_data_vpc_sc,
    module.landing_zone_vpc_sc
  ]
}

resource "time_sleep" "wait_for_bridge_propagation" {
  create_duration = "240s"

  depends_on = [
    module.vpc_sc_bridge_confidential_landing_zone,
    module.vpc_sc_bridge_confidential_governance,
    module.vpc_sc_bridge_landing_zone_governance
  ]
}
