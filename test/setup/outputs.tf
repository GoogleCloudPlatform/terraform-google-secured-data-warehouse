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
  value = values(module.data_ingestion_project)[*].project_id
}

output "data_governance_project_id" {
  value = values(module.data_governance_project)[*].project_id
}

output "datalake_project_id" {
  value = values(module.datalake_project)[*].project_id
}

output "confidential_data_project_id" {
  value = values(module.confidential_data_project)[*].project_id
}

output "external_flex_template_project_id" {
  value = module.external_flex_template_project.project_id
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

output "java_de_identify_template_gs_path" {
  value = local.java_de_identify_template_gs_path

  depends_on = [
    null_resource.java_de_identification_flex_template
  ]
}

output "java_re_identify_template_gs_path" {
  value = local.java_re_identify_template_gs_path

  depends_on = [
    null_resource.java_re_identification_flex_template
  ]
}

output "python_de_identify_template_gs_path" {
  value = local.python_de_identify_template_gs_path

  depends_on = [
    null_resource.python_de_identification_flex_template
  ]
}

output "python_re_identify_template_gs_path" {
  value = local.python_re_identify_template_gs_path

  depends_on = [
    null_resource.python_re_identification_flex_template
  ]
}

output "sdx_project_number" {
  description = "The Project Number to configure Secure data exchange with egress rule for the dataflow templates."
  value       = module.external_flex_template_project.project_number
}

output "data_ingestion_network_name" {
  description = "The name of the data ingestion VPC being created."
  value       = values(module.dwh_networking_ingestion)[*].network_name
}

output "data_ingestion_network_self_link" {
  description = "The URI of the data ingestion VPC being created."
  value       = values(module.dwh_networking_ingestion)[*].network_self_link
}

output "data_ingestion_subnets_self_link" {
  description = "The self-links of data ingestion subnets being created."
  value       = values(module.dwh_networking_ingestion)[*].subnets_self_links[0]
}

output "confidential_network_name" {
  description = "The name of the confidential VPC being created."
  value       = values(module.dwh_networking_confidential)[*].network_name
}

output "confidential_network_self_link" {
  description = "The URI of the confidential VPC being created."
  value       = values(module.dwh_networking_confidential)[*].network_self_link
}

output "confidential_subnets_self_link" {
  description = "The self-links of confidential subnets being created."
  value       = values(module.dwh_networking_confidential)[*].subnets_self_links[0]
}
