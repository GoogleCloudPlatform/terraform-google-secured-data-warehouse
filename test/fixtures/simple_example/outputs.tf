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


output "project_id" {
  description = "The project_id used to create infra."
  value       = var.data_ingestion_project_id
}

output "data_governance_project_id" {
  description = "The data_governance_project_id used to create infra."
  value       = var.data_governance_project_id
}

output "datalake_project_id" {
  description = "The datalake_project_id used to create bigquery."
  value       = var.datalake_project_id
}

output "org_id" {
  description = "The organization used to create infra."
  value       = var.org_id
}

output "organization_policy_name" {
  description = "The organization policy name used to create infra."
  value       = var.access_context_manager_policy_id
}

output "dataflow_controller_service_account_email" {
  description = "The service account email."
  value       = module.simple_example.dataflow_controller_service_account_email
}

output "storage_writer_service_account_email" {
  description = "The service account email."
  value       = module.simple_example.storage_writer_service_account_email
}

output "pubsub_writer_service_account_email" {
  description = "The service account email."
  value       = module.simple_example.pubsub_writer_service_account_email
}

output "data_ingest_bucket_names" {
  description = "The name list of the buckets created for data ingest pipeline."
  value       = module.simple_example.data_ingest_bucket_names
}

output "data_ingest_topic_name" {
  description = "The topic created for data ingest pipeline."
  value       = module.simple_example.data_ingest_topic_name
}

output "data_ingest_bigquery_dataset" {
  description = "The bigquery dataset created for data ingest pipeline."
  value       = module.simple_example.data_ingest_bigquery_dataset
}

output "network_name" {
  description = "The name of the VPC being created."
  value       = module.simple_example.network_name
}

output "network_self_link" {
  description = "The URI of the VPC being created."
  value       = module.simple_example.network_self_link
}

output "subnets_names" {
  description = "The names of the subnets being created."
  value       = module.simple_example.subnets_names
}

output "subnets_ips" {
  description = "The IPs and CIDRs of the subnets being created."
  value       = module.simple_example.subnets_ips
}

output "access_level_name" {
  description = "Access context manager access level name."
  value       = module.simple_example.data_ingestion_access_level_name
}

output "service_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = module.simple_example.data_ingestion_service_perimeter_name
}

output "cmek_keyring_name" {
  description = "The Keyring name for the KMS Customer Managed Encryption Keys."
  value       = module.simple_example.cmek_keyring_name
}

output "cmek_keyring_full_name" {
  description = "The Keyring full name for the KMS Customer Managed Encryption Keys."
  value       = module.simple_example.cmek_keyring_full_name
}
