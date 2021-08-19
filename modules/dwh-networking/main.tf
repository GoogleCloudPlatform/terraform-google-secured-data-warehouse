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
  suffix                         = var.commom_suffix != "" ? var.commom_suffix : random_id.suffix.hex
  actual_policy                  = var.access_context_manager_policy_id != "" ? var.access_context_manager_policy_id : google_access_context_manager_access_policy.access_policy[0].name
  perimeter_name                 = "regular_perimeter_data_warehouse_${local.suffix}"
  regular_service_perimeter_name = "accessPolicies/${local.actual_policy}/servicePerimeters/${local.perimeter_name}"
  access_policy_name             = "enterprise_data_warehouse_policy_${local.suffix}"
}

resource "google_access_context_manager_access_policy" "access_policy" {
  count  = var.access_context_manager_policy_id != "" ? 0 : 1
  parent = "organizations/${var.org_id}"
  title  = "default policy"
}

resource "random_id" "suffix" {
  byte_length = 4
}

data "google_project" "target_project" {
  project_id = var.project_id
}

module "access_level_policy" {
  source      = "terraform-google-modules/vpc-service-controls/google//modules/access_level"
  version     = "~> 3.0"
  policy      = local.actual_policy
  name        = local.access_policy_name
  description = "policy with all available options to configure"

  members = var.perimeter_members

  ip_subnetworks = var.access_level_ip_subnetworks
  regions        = var.access_level_regions
}

module "regular_service_perimeter" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  version = "~> 3.0"

  policy         = local.actual_policy
  perimeter_name = local.perimeter_name
  description    = "perimeter for data warehouse projects"

  resources           = [data.google_project.target_project.number]
  restricted_services = var.restricted_services

  access_levels = [
    module.access_level_policy.name
  ]
}
