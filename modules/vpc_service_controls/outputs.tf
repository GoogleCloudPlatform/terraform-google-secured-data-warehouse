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
  value       = module.network.network_name
  description = "The name of the VPC being created."
}

output "project_number" {
  value       = data.google_project.target_project.number
  description = "the project number that is included on the perimeter."
}

output "network_self_link" {
  value       = module.network.network_self_link
  description = "The URI of the VPC being created."
}

output "subnets_names" {
  value       = module.network.subnets_names
  description = "The names of the subnets being created."
}

output "subnets_ips" {
  value       = module.network.subnets_ips
  description = "The IPs and CIDRs of the subnets being created"
}

output "subnets_self_links" {
  value       = module.network.subnets_self_links
  description = "The self-links of subnets being created"
}

output "subnets_regions" {
  value       = module.network.subnets_regions
  description = "The region where the subnets will be created"
}

output "access_level_name" {
  value       = module.access_level_policy.name
  description = "Access context manager access level name"
}

output "service_perimeter_name" {
  value       = local.regular_service_perimeter_name
  description = "Access context manager service perimeter name"
}
