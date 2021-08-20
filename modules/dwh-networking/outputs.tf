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


output "network_name" {
  description = "The name of the VPC being created."
  value       = module.network.network_name

  depends_on = [
    time_sleep.wait_for_vpc_sc_propagation
  ]
}

output "project_number" {
  description = "The project number that is included on the perimeter."
  value       = data.google_project.target_project.number

  depends_on = [
    time_sleep.wait_for_vpc_sc_propagation
  ]
}

output "network_self_link" {
  description = "The URI of the VPC being created."
  value       = module.network.network_self_link

  depends_on = [
    time_sleep.wait_for_vpc_sc_propagation
  ]
}

output "subnets_names" {
  description = "The names of the subnets being created."
  value       = module.network.subnets_names

  depends_on = [
    time_sleep.wait_for_vpc_sc_propagation
  ]
}

output "subnets_ips" {
  description = "The IPs and CIDRs of the subnets being created."
  value       = module.network.subnets_ips

  depends_on = [
    time_sleep.wait_for_vpc_sc_propagation
  ]
}

output "subnets_self_links" {
  description = "The self-links of subnets being created."
  value       = module.network.subnets_self_links

  depends_on = [
    time_sleep.wait_for_vpc_sc_propagation
  ]
}

output "subnets_regions" {
  description = "The region where the subnets will be created."
  value       = module.network.subnets_regions

  depends_on = [
    time_sleep.wait_for_vpc_sc_propagation
  ]
}

output "access_level_name" {
  description = "The access level name for the Access Context Manager."
  value       = module.access_level_policy.name

  depends_on = [
    time_sleep.wait_for_vpc_sc_propagation
  ]
}

output "service_perimeter_name" {
  description = "The service perimeter name for the Access Context Manager."
  value       = local.regular_service_perimeter_name

  depends_on = [
    time_sleep.wait_for_vpc_sc_propagation
  ]
}
