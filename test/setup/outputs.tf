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

output "data_ingestion_project_id" {
  value = module.data_ingestion_project.project_id
}

output "data_governance_project_id" {
  value = module.data_governance_project.project_id
}

output "datalake_project_id" {
  value = module.datalake_project.project_id
}

output "privileged_data_project_id" {
  value = module.privileged_data_project.project_id
}

output "ext_artifact_registry_project_id" {
  value = module.ext_artifact_registry_project.project_id
}

output "sa_key" {
  value     = google_service_account_key.int_test.private_key
  sensitive = true
}

output "terraform_service_account" {
  value = google_service_account.int_ci_service_account.email
}

output "org_project_creators" {
  value = ["serviceAccount:${google_service_account.int_ci_service_account.email}"]
}

output "org_id" {
  value = var.org_id
}

output "billing_account" {
  value = var.billing_account
}

output "data_ingestion_network_name" {
  description = "The name of the data ingestion VPC being created."
  value       = module.dwh_networking_ingestion.network_name
}

output "data_ingestion_network_self_link" {
  description = "The URI of the data ingestion VPC being created."
  value       = module.dwh_networking_ingestion.network_self_link
}

output "data_ingestion_subnets_self_link" {
  description = "The self-links of data ingestion subnets being created."
  value       = module.dwh_networking_ingestion.subnets_self_links[0]
}

output "privileged_network_name" {
  description = "The name of the confidential VPC being created."
  value       = module.dwh_networking_privileged.network_name
}

output "privileged_network_self_link" {
  description = "The URI of the confidential VPC being created."
  value       = module.dwh_networking_privileged.network_self_link
}

output "privileged_subnets_self_link" {
  description = "The self-links of confidential subnets being created."
  value       = module.dwh_networking_privileged.subnets_self_links[0]
}
