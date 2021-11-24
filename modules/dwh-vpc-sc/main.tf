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
  suffix                         = var.common_suffix != "" ? var.common_suffix : random_id.suffix.hex
  actual_policy                  = var.access_context_manager_policy_id != "" ? var.access_context_manager_policy_id : google_access_context_manager_access_policy.access_policy[0].name
  perimeter_name                 = "rp_dwh_${var.common_name}_${local.suffix}"
  regular_service_perimeter_name = "accessPolicies/${local.actual_policy}/servicePerimeters/${local.perimeter_name}"
  access_policy_name             = "ac_dwh_${var.common_name}_${local.suffix}"
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

# Can not use the module "terraform-google-modules/vpc-service-controls/google/modules/regular_service_perimeter"
# because we need to set the  lifecycle of the resource.
resource "google_access_context_manager_service_perimeter" "regular_service_perimeter" {
  provider       = google
  parent         = "accessPolicies/${local.actual_policy}"
  perimeter_type = "PERIMETER_TYPE_REGULAR"
  name           = "accessPolicies/${local.actual_policy}/servicePerimeters/${local.perimeter_name}"
  title          = local.perimeter_name
  description    = "perimeter for data warehouse projects"

  status {
    restricted_services = var.restricted_services
    resources           = formatlist("projects/%s", var.resources)
    access_levels = formatlist(
      "accessPolicies/${local.actual_policy}/accessLevels/%s",
      [module.access_level_policy.name]
    )

    dynamic "egress_policies" {
      for_each = var.egress_policies
      content {
        egress_from {
          identity_type = lookup(egress_policies.value["from"], "identity_type", null)
          identities    = lookup(egress_policies.value["from"], "identities", null)
        }
        egress_to {
          resources = lookup(egress_policies.value["to"], "resources", ["*"])
          dynamic "operations" {
            for_each = lookup(egress_policies.value["to"], "operations", [])
            content {
              service_name = operations.key
              dynamic "method_selectors" {
                for_each = merge(
                  { for k, v in lookup(operations.value, "methods", {}) : v => "method" },
                { for k, v in lookup(operations.value, "permissions", {}) : v => "permission" })
                content {
                  method     = method_selectors.value == "method" ? method_selectors.key : ""
                  permission = method_selectors.value == "permission" ? method_selectors.key : ""
                }
              }
            }
          }
        }
      }
    }
  }
}

resource "time_sleep" "wait_for_vpc_sc_propagation" {
  create_duration = "240s"

  depends_on = [
    module.access_level_policy,
    google_access_context_manager_service_perimeter.regular_service_perimeter
  ]
}
