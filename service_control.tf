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
    "serviceAccount:${module.data_ingestion.scheduler_service_account_email}",
    "serviceAccount:${var.terraform_service_account}"
  ], var.perimeter_additional_members))

  perimeter_members_governance = distinct(concat([
    "serviceAccount:${var.terraform_service_account}"
  ], var.perimeter_additional_members))

  perimeter_members_confidential = distinct(concat([
    "serviceAccount:${var.terraform_service_account}"
  ], var.perimeter_additional_members))

  data_ingestion_vpc_sc_resources = {
    data_ingestion   = data.google_project.data_ingestion_project.number
    non_confidential = data.google_project.non_confidential_data_project.number
  }

  data_governance_vpc_sc_resources = {
    governance = data.google_project.governance_project.number
  }

  confidential_data_vpc_sc_resources = {
    confidential = data.google_project.confidential_project.number
  }

  actual_policy = var.access_context_manager_policy_id != "" ? var.access_context_manager_policy_id : google_access_context_manager_access_policy.access_policy[0].name

  data_ingestion_default_egress_rule = var.sdx_project_number == "" ? [] : [
    {
      "from" = {
        "identity_type" = ""
        "identities" = distinct(concat(
          var.data_ingestion_dataflow_deployer_identities,
          ["serviceAccount:${var.terraform_service_account}", "serviceAccount:${module.data_ingestion.dataflow_controller_service_account_email}"]
        ))
      },
      "to" = {
        "resources" = ["projects/${var.sdx_project_number}"]
        "operations" = {
          "storage.googleapis.com" = {
            "methods" = [
              "google.storage.objects.get"
            ]
          },
          "artifactregistry.googleapis.com" = {
            "methods" = [
              "*"
            ]
          }
        }
      }
    },
  ]

  confidential_data_default_egress_rule = var.sdx_project_number == "" ? [] : [
    {
      "from" = {
        "identity_type" = ""
        "identities" = distinct(concat(
          var.confidential_data_dataflow_deployer_identities,
          ["serviceAccount:${var.terraform_service_account}", "serviceAccount:${module.bigquery_confidential_data.confidential_dataflow_controller_service_account_email}"]
        ))
      },
      "to" = {
        "resources" = ["projects/${var.sdx_project_number}"]
        "operations" = {
          "storage.googleapis.com" = {
            "methods" = [
              "google.storage.objects.get"
            ]
          },
          "artifactregistry.googleapis.com" = {
            "methods" = [
              "*"
            ]
          }
        }
      }
    },
  ]

  confidential_data_bigquery_egress_rule = var.sdx_project_number == "" ? [] : [
    {
      "from" = {
        "identity_type" = ""
        "identities" = distinct(concat(
          var.confidential_data_dataflow_deployer_identities,
          ["serviceAccount:${var.terraform_service_account}", "serviceAccount:${module.bigquery_confidential_data.confidential_dataflow_controller_service_account_email}"]
        ))
      },
      "to" = {
        "resources" = ["projects/${var.sdx_project_number}"]
        "operations" = {
          "bigquery.googleapis.com" = {
            "methods" = [
              "*"
            ]
          }
        }
      }
    }
  ]
}

resource "google_access_context_manager_access_policy" "access_policy" {
  count  = var.access_context_manager_policy_id != "" ? 0 : 1
  parent = "organizations/${var.org_id}"
  title  = "default policy"
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

# Default VPC Service Controls perimeter and access list.
module "data_ingestion_vpc_sc" {
  source = ".//modules/dwh-vpc-sc"

  count = var.data_ingestion_perimeter == "" ? 1 : 0

  access_context_manager_policy_id              = local.actual_policy
  common_name                                   = "data_ingestion"
  common_suffix                                 = random_id.suffix.hex
  resources                                     = local.data_ingestion_vpc_sc_resources
  perimeter_members                             = local.perimeter_members_data_ingestion
  access_level_combining_function               = var.data_ingestion_access_level_combining_function
  access_level_ip_subnetworks                   = var.data_ingestion_access_level_ip_subnetworks
  access_level_negate                           = var.data_ingestion_access_level_negate
  access_level_require_screen_lock              = var.data_ingestion_access_level_require_screen_lock
  access_level_require_corp_owned               = var.data_ingestion_access_level_require_corp_owned
  access_level_allowed_encryption_statuses      = var.data_ingestion_access_level_allowed_encryption_statuses
  access_level_allowed_device_management_levels = var.data_ingestion_access_level_allowed_device_management_levels
  access_level_minimum_version                  = var.data_ingestion_access_level_minimum_version
  access_level_os_type                          = var.data_ingestion_access_level_os_type
  required_access_levels                        = var.data_ingestion_required_access_levels
  access_level_regions                          = var.data_ingestion_access_level_regions



  egress_policies = distinct(concat(
    local.data_ingestion_default_egress_rule,
    var.data_ingestion_egress_policies
  ))

  ingress_policies = var.data_ingestion_ingress_policies

  # depends_on needed to prevent intermittent errors
  # when the VPC-SC is created but perimeter member
  # not yet propagated.
  depends_on = [
    time_sleep.forces_wait_propagation
  ]
}

# Adding project to an existing VPC Service Controls Perimeter
# instead of the default VPC Service Controls perimeter.
# The default VPC Service Controls perimeter and access list will not be created.
resource "google_access_context_manager_service_perimeter_resource" "ingestion_perimeter_resource" {
  count = var.data_ingestion_perimeter != "" ? 1 : 0

  perimeter_name = "accessPolicies/${local.actual_policy}/servicePerimeters/${var.data_ingestion_perimeter}"
  resource       = "projects/${data.google_project.data_ingestion_project.number}"

  depends_on = [
    time_sleep.forces_wait_propagation
  ]
}

resource "google_access_context_manager_service_perimeter_resource" "non_confidential_perimeter_resource" {
  count = var.data_ingestion_perimeter != "" ? 1 : 0

  perimeter_name = "accessPolicies/${local.actual_policy}/servicePerimeters/${var.data_ingestion_perimeter}"
  resource       = "projects/${data.google_project.non_confidential_data_project.number}"

  depends_on = [
    time_sleep.forces_wait_propagation
  ]
}

# Default VPC Service Controls perimeter and access list.
module "data_governance_vpc_sc" {
  source = ".//modules/dwh-vpc-sc"

  count = var.data_governance_perimeter == "" ? 1 : 0

  access_context_manager_policy_id = local.actual_policy
  common_name                      = "data_governance"
  common_suffix                    = random_id.suffix.hex
  resources                        = local.data_governance_vpc_sc_resources
  perimeter_members                = local.perimeter_members_governance

  egress_policies  = var.data_governance_egress_policies
  ingress_policies = var.data_governance_ingress_policies

  access_level_combining_function               = var.data_governance_access_level_combining_function
  access_level_ip_subnetworks                   = var.data_governance_access_level_ip_subnetworks
  access_level_negate                           = var.data_governance_access_level_negate
  access_level_require_screen_lock              = var.data_governance_access_level_require_screen_lock
  access_level_require_corp_owned               = var.data_governance_access_level_require_corp_owned
  access_level_allowed_encryption_statuses      = var.data_governance_access_level_allowed_encryption_statuses
  access_level_allowed_device_management_levels = var.data_governance_access_level_allowed_device_management_levels
  access_level_minimum_version                  = var.data_governance_access_level_minimum_version
  access_level_os_type                          = var.data_governance_access_level_os_type
  required_access_levels                        = var.data_governance_required_access_levels
  access_level_regions                          = var.data_governance_access_level_regions

  # depends_on needed to prevent intermittent errors
  # when the VPC-SC is created but perimeter member
  # not yet propagated.
  depends_on = [
    time_sleep.forces_wait_propagation
  ]
}

# Adding project to an existing VPC Service Controls Perimeter
# instead of the default VPC Service Controls perimeter.
# The default VPC Service Controls perimeter and access list will not be created.
resource "google_access_context_manager_service_perimeter_resource" "governance_perimeter_resource" {
  count = var.data_governance_perimeter != "" ? 1 : 0

  perimeter_name = "accessPolicies/${local.actual_policy}/servicePerimeters/${var.data_governance_perimeter}"
  resource       = "projects/${data.google_project.governance_project.number}"

  depends_on = [
    time_sleep.forces_wait_propagation
  ]
}

# Default VPC Service Controls perimeter and access list.
module "confidential_data_vpc_sc" {
  source = ".//modules/dwh-vpc-sc"

  count = var.confidential_data_perimeter == "" ? 1 : 0

  access_context_manager_policy_id = local.actual_policy
  common_name                      = "confidential_data"
  common_suffix                    = random_id.suffix.hex
  resources                        = local.confidential_data_vpc_sc_resources
  perimeter_members                = local.perimeter_members_confidential

  egress_policies = distinct(concat(
    local.confidential_data_default_egress_rule,
    local.confidential_data_bigquery_egress_rule,
    var.confidential_data_egress_policies
  ))

  ingress_policies = var.confidential_data_ingress_policies

  access_level_combining_function               = var.confidential_data_access_level_combining_function
  access_level_ip_subnetworks                   = var.confidential_data_access_level_ip_subnetworks
  access_level_negate                           = var.confidential_data_access_level_negate
  access_level_require_screen_lock              = var.confidential_data_access_level_require_screen_lock
  access_level_require_corp_owned               = var.confidential_data_access_level_require_corp_owned
  access_level_allowed_encryption_statuses      = var.confidential_data_access_level_allowed_encryption_statuses
  access_level_allowed_device_management_levels = var.confidential_data_access_level_allowed_device_management_levels
  access_level_minimum_version                  = var.confidential_data_access_level_minimum_version
  access_level_os_type                          = var.confidential_data_access_level_os_type
  required_access_levels                        = var.confidential_data_required_access_levels
  access_level_regions                          = var.confidential_data_access_level_regions

  # depends_on needed to prevent intermittent errors
  # when the VPC-SC is created but perimeter member
  # not yet propagated.
  depends_on = [
    time_sleep.forces_wait_propagation
  ]
}

# Adding project to an existing VPC Service Controls Perimeter
# instead of the default VPC Service Controls perimeter.
# The default VPC Service Controls perimeter and access list will not be created.
resource "google_access_context_manager_service_perimeter_resource" "confidential_perimeter_resource" {
  count = var.confidential_data_perimeter != "" ? 1 : 0

  perimeter_name = "accessPolicies/${local.actual_policy}/servicePerimeters/${var.confidential_data_perimeter}"
  resource       = "projects/${data.google_project.confidential_project.number}"

  depends_on = [
    time_sleep.forces_wait_propagation
  ]
}

module "vpc_sc_bridge_data_ingestion_governance" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/bridge_service_perimeter"
  version = "~> 5.1"

  policy         = local.actual_policy
  perimeter_name = "vpc_sc_bridge_data_ingestion_governance_${random_id.suffix.hex}"
  description    = "VPC-SC bridge between data ingestion and data governance"

  resources = [
    data.google_project.data_ingestion_project.number,
    data.google_project.governance_project.number,
    data.google_project.non_confidential_data_project.number
  ]
  resource_keys = [0, 1, 2]

  depends_on = [
    time_sleep.forces_wait_propagation,
    module.data_governance_vpc_sc,
    module.data_ingestion_vpc_sc,
    google_access_context_manager_service_perimeter_resource.ingestion_perimeter_resource,
    google_access_context_manager_service_perimeter_resource.governance_perimeter_resource,
    google_access_context_manager_service_perimeter_resource.non_confidential_perimeter_resource,
  ]
}

module "vpc_sc_bridge_confidential_governance" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/bridge_service_perimeter"
  version = "~> 5.1"

  policy         = local.actual_policy
  perimeter_name = "vpc_sc_bridge_confidential_governance_${random_id.suffix.hex}"
  description    = "VPC-SC bridge between confidential data and data governance"

  resources = [
    data.google_project.confidential_project.number,
    data.google_project.governance_project.number
  ]
  resource_keys = [0, 1]

  depends_on = [
    time_sleep.forces_wait_propagation,
    module.confidential_data_vpc_sc,
    module.data_governance_vpc_sc,
    google_access_context_manager_service_perimeter_resource.confidential_perimeter_resource,
    google_access_context_manager_service_perimeter_resource.governance_perimeter_resource
  ]
}

module "vpc_sc_bridge_confidential_data_ingestion" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/bridge_service_perimeter"
  version = "~> 5.1"

  policy         = local.actual_policy
  perimeter_name = "vpc_sc_bridge_confidential_data_ingestion_${random_id.suffix.hex}"
  description    = "VPC-SC bridge between confidential data and data ingestion"

  resources = [
    data.google_project.confidential_project.number,
    data.google_project.non_confidential_data_project.number
  ]

  resource_keys = [0, 1]

  depends_on = [
    time_sleep.forces_wait_propagation,
    module.confidential_data_vpc_sc,
    module.data_ingestion_vpc_sc,
    google_access_context_manager_service_perimeter_resource.confidential_perimeter_resource,
    google_access_context_manager_service_perimeter_resource.non_confidential_perimeter_resource,
    google_access_context_manager_service_perimeter_resource.ingestion_perimeter_resource
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
