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

output "landing_zone_project_id" {
  description = "(optional) describe your variable"
  value       = module.landing_zone_project.project_id
}

output "non_confidential_data_project_id" {
  description = "(optional) describe your variable"
  value       = module.non_confidential_data_project.project_id
}

output "data_governance_project_id" {
  description = "(optional) describe your variable"
  value       = module.data_governance_project.project_id
}

output "confidential_data_project_id" {
  description = "(optional) describe your variable"
  value       = module.confidential_data_project.project_id
}

output "landing_zone_network_name" {
  description = "The name of the landing zone VPC being created."
  value       = module.dwh_networking_landing_zone.network_name
}

output "landing_zone_network_self_link" {
  description = "The URI of the landing zone VPC being created."
  value       = module.dwh_networking_landing_zone.network_self_link
}

output "landing_zone_subnets_self_link" {
  description = "The self-links of landing zone subnets being created."
  value       = module.dwh_networking_landing_zone.subnets_self_links[0]
}

output "confidential_network_name" {
  description = "The name of the confidential VPC being created."
  value       = module.dwh_networking_confidential.network_name
}

output "confidential_network_self_link" {
  description = "The URI of the confidential VPC being created."
  value       = module.dwh_networking_confidential.network_self_link
}

output "confidential_subnets_self_link" {
  description = "The self-links of confidential subnets being created."
  value       = module.dwh_networking_confidential.subnets_self_links[0]
}
