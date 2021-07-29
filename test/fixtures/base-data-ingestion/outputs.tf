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
  value       = var.project_id
}

output "project_number" {
  description = "The project_number used to create infra."
  value       = module.data_ingestion.project_number
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
  value       = module.data_ingestion.dataflow_controller_service_account_email
}

output "storage_writer_service_account_email" {
  description = "The service account email."
  value       = module.data_ingestion.storage_writer_service_account_email
}

output "pubsub_writer_service_account_email" {
  description = "The service account email."
  value       = module.data_ingestion.pubsub_writer_service_account_email
}

output "data_ingest_bucket_names" {
  description = "The name list of the buckets created for data ingest pipeline."
  value       = module.data_ingestion.data_ingest_bucket_names
}

output "data_ingest_topic_name" {
  description = "The topic created for data ingest pipeline."
  value       = module.data_ingestion.data_ingest_topic_name
}

output "data_ingest_bigquery_dataset" {
  description = "The bigquery dataset created for data ingest pipeline."
  value       = module.data_ingestion.data_ingest_bigquery_dataset
}

output "data_ingest_bigquery_dataset_id" {
  description = "The bigquery dataset_id created for data ingest pipeline."
  value       = module.data_ingestion.data_ingest_bigquery_dataset.id
}

output "network_name" {
  value       = module.data_ingestion.network_name
  description = "The name of the VPC being created."
}

output "network_self_link" {
  value       = module.data_ingestion.network_self_link
  description = "The URI of the VPC being created."
}

output "subnets_names" {
  value       = module.data_ingestion.subnets_names
  description = "The names of the subnets being created."
}

output "subnets_ips" {
  value       = module.data_ingestion.subnets_ips
  description = "The IPs and CIDRs of the subnets being created."
}

output "subnetwork_self_link" {
  value       = module.data_ingestion.subnets_self_links[0]
  description = "The self-link of subnet being created."
}

output "subnets_regions" {
  value       = module.data_ingestion.subnets_regions
  description = "The region where the subnets will be created."
}

output "access_level_name" {
  value       = module.data_ingestion.access_level_name
  description = "Access context manager access level name."
}

output "service_perimeter_name" {
  value       = module.data_ingestion.service_perimeter_name
  description = "Access context manager service perimeter name."
}

output "perimeter_additional_members" {
  description = "The list additional members to be added on perimeter access. Prefix of group: user: or serviceAccount: is required."
  value       = var.perimeter_additional_members
}

output "terraform_service_account" {
  description = "The email address of the service account that will run the Terraform code."
  value       = var.terraform_service_account
}

output "cmek_location" {
  description = "The location for the KMS Customer Managed Encryption Keys."
  value       = var.cmek_location
}

output "cmek_keyring_name" {
  description = "The Keyring name for the KMS Customer Managed Encryption Keys."
  value       = module.data_ingestion.cmek_keyring_name
}

output "cmek_keyring_full_name" {
  description = "The Keyring full name for the KMS Customer Managed Encryption Keys."
  value       = module.data_ingestion.cmek_keyring_full_name
}

output "default_storage_sa" {
  description = "The default Storage service account granted encrypt/decrypt permission on the KMS key."
  value       = module.data_ingestion.default_storage_sa
}

output "default_pubsub_sa" {
  description = "The default Pub/Sub service account granted encrypt/decrypt permission on the KMS key."
  value       = module.data_ingestion.default_pubsub_sa
}

output "default_bigquery_sa" {
  description = "The default Bigquery service account granted encrypt/decrypt permission on the KMS key."
  value       = module.data_ingestion.default_bigquery_sa
}
