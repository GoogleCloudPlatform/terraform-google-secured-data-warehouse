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
  perimeter_members_data_ingestion = distinct(concat([
    "serviceAccount:${module.data_ingestion.dataflow_controller_service_account_email}",
    "serviceAccount:${module.data_ingestion.storage_writer_service_account_email}",
    "serviceAccount:${module.data_ingestion.pubsub_writer_service_account_email}",
    "serviceAccount:${var.terraform_service_account}"
  ], var.perimeter_additional_members))

  perimeter_members_governance = distinct(concat([
    "serviceAccount:${var.terraform_service_account}"
  ], var.perimeter_additional_members))

  perimeter_members_confidential = distinct(concat([
    "serviceAccount:${var.terraform_service_account}"
  ], var.perimeter_additional_members))

  base_restricted_services = [
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
    "sts.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com"
  ]

  restricted_services = distinct(concat(local.base_restricted_services, var.additional_restricted_services))

}

data "google_project" "data_ingestion_project" {
  project_id = var.data_ingestion_project_id
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
    module.data_ingestion,
    module.org_policies,
    module.data_governance,
    module.bigquery_confidential_data
  ]
}

module "data_ingestion_vpc_sc" {
  source = ".//modules/dwh-vpc-sc"

  count = var.external_data_ingestion_perimeter == "" ? 1 : 0

  org_id                           = var.org_id
  project_id                       = var.data_ingestion_project_id
  access_context_manager_policy_id = var.access_context_manager_policy_id
  common_name                      = "data_ingestion"
  common_suffix                    = random_id.suffix.hex
  resources                        = [data.google_project.data_ingestion_project.number, data.google_project.non_confidential_data_project.number]
  perimeter_members                = local.perimeter_members_data_ingestion
  restricted_services              = local.restricted_services

  egress_policies = distinct(concat([
    {
      "from" = {
        "identity_type" = ""
        "identities" = distinct(concat(
          var.data_ingestion_dataflow_deployer_identities,
          ["serviceAccount:${var.terraform_service_account}"]
        ))
      },
      "to" = {
        "resources" = ["projects/${var.sdx_project_number}"]
        "operations" = {
          "storage.googleapis.com" = {
            "methods" = [
              "google.storage.objects.get"
            ]
          }
        }
      }
    },
  ], var.data_ingestion_egress_policies))

  # depends_on needed to prevent intermittent errors
  # when the VPC-SC is created but perimeter member
  # not yet propagated.
  depends_on = [
    time_sleep.forces_wait_propagation
  ]
}

resource "google_access_context_manager_service_perimeter_resource" "ingestion-perimeter-resource" {
  count = var.external_data_ingestion_perimeter != "" ? 1 : 0

  perimeter_name = var.external_data_ingestion_perimeter
  resource       = "projects/${data.google_project.data_ingestion_project.number}"

  depends_on = [
    time_sleep.forces_wait_propagation
  ]
}

resource "google_access_context_manager_service_perimeter_resource" "non-confidential-perimeter-resource" {
  count = var.external_data_ingestion_perimeter != "" ? 1 : 0

  perimeter_name = var.external_data_ingestion_perimeter
  resource       = "projects/${data.google_project.non_confidential_data_project.number}"

  depends_on = [
    time_sleep.forces_wait_propagation
  ]
}

module "data_governance_vpc_sc" {
  source = ".//modules/dwh-vpc-sc"

  count = var.external_data_governance_perimeter == "" ? 1 : 0

  org_id                           = var.org_id
  project_id                       = var.data_governance_project_id
  access_context_manager_policy_id = var.access_context_manager_policy_id
  common_name                      = "data_governance"
  common_suffix                    = random_id.suffix.hex
  resources                        = [data.google_project.governance_project.number]
  perimeter_members                = local.perimeter_members_governance
  restricted_services              = local.restricted_services

  egress_policies = var.data_governance_egress_policies

  # depends_on needed to prevent intermittent errors
  # when the VPC-SC is created but perimeter member
  # not yet propagated.
  depends_on = [
    time_sleep.forces_wait_propagation
  ]
}

resource "google_access_context_manager_service_perimeter_resource" "governance-perimeter-resource" {
  count = var.external_data_governance_perimeter != "" ? 1 : 0

  perimeter_name = var.external_data_governance_perimeter
  resource       = "projects/${data.google_project.governance_project.number}"

  depends_on = [
    time_sleep.forces_wait_propagation
  ]
}

module "confidential_data_vpc_sc" {
  source = ".//modules/dwh-vpc-sc"

  count = var.external_confidential_data_perimeter == "" ? 1 : 0

  org_id                           = var.org_id
  project_id                       = var.confidential_data_project_id
  access_context_manager_policy_id = var.access_context_manager_policy_id
  common_name                      = "confidential_data"
  common_suffix                    = random_id.suffix.hex
  resources                        = [data.google_project.confidential_project.number]
  perimeter_members                = local.perimeter_members_confidential
  restricted_services              = local.restricted_services

  egress_policies = distinct(concat([
    {
      "from" = {
        "identity_type" = ""
        "identities" = distinct(concat(
          var.confidential_data_dataflow_deployer_identities,
          ["serviceAccount:${var.terraform_service_account}"]
        ))
      },
      "to" = {
        "resources" = ["projects/${var.sdx_project_number}"]
        "operations" = {
          "storage.googleapis.com" = {
            "methods" = [
              "google.storage.objects.get"
            ]
          }
        }
      }
    }
  ], var.confidential_data_egress_policies))

  # depends_on needed to prevent intermittent errors
  # when the VPC-SC is created but perimeter member
  # not yet propagated.
  depends_on = [
    time_sleep.forces_wait_propagation
  ]
}

resource "google_access_context_manager_service_perimeter_resource" "confidential-perimeter-resource" {
  count = var.external_confidential_data_perimeter != "" ? 1 : 0

  perimeter_name = "accessPolicies/${var.access_context_manager_policy_id}/servicePerimeters/${var.external_confidential_data_perimeter}"
  resource       = "projects/${data.google_project.confidential_project.number}"

  depends_on = [
    time_sleep.forces_wait_propagation
  ]
}

module "vpc_sc_bridge_data_ingestion_governance" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/bridge_service_perimeter"
  version = "~> 3.0"

  policy         = var.access_context_manager_policy_id
  perimeter_name = "vpc_sc_bridge_data_ingestion_governance_${random_id.suffix.hex}"
  description    = "VPC-SC bridge between data ingestion and data governance"

  resources = [
    data.google_project.data_ingestion_project.number,
    data.google_project.governance_project.number,
    data.google_project.non_confidential_data_project.number
  ]

  depends_on = [
    time_sleep.forces_wait_propagation,
    module.data_governance_vpc_sc,
    module.data_ingestion_vpc_sc,
    google_access_context_manager_service_perimeter_resource.ingestion-perimeter-resource,
    google_access_context_manager_service_perimeter_resource.governance-perimeter-resource,
    google_access_context_manager_service_perimeter_resource.non-confidential-perimeter-resource,
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
    module.data_governance_vpc_sc,
    google_access_context_manager_service_perimeter_resource.confidential-perimeter-resource,
    google_access_context_manager_service_perimeter_resource.governance-perimeter-resource
  ]
}

module "vpc_sc_bridge_confidential_data_ingestion" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/bridge_service_perimeter"
  version = "~> 3.0"

  policy         = var.access_context_manager_policy_id
  perimeter_name = "vpc_sc_bridge_confidential_data_ingestion_${random_id.suffix.hex}"
  description    = "VPC-SC bridge between confidential data and data ingestion"

  resources = [
    data.google_project.confidential_project.number,
    data.google_project.non_confidential_data_project.number
  ]

  depends_on = [
    time_sleep.forces_wait_propagation,
    module.confidential_data_vpc_sc,
    module.data_ingestion_vpc_sc,
    google_access_context_manager_service_perimeter_resource.confidential-perimeter-resource,
    google_access_context_manager_service_perimeter_resource.non-confidential-perimeter-resource,
    google_access_context_manager_service_perimeter_resource.ingestion-perimeter-resource
  ]
}

resource "time_sleep" "wait_for_bridge_propagation" {
  create_duration = "240s"

  depends_on = [
    module.vpc_sc_bridge_confidential_data_ingestion,
    module.vpc_sc_bridge_confidential_governance,
    module.vpc_sc_bridge_data_ingestion_governance
  ]
}
