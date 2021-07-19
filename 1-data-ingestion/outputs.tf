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

output "dataflow_controller_service_account_email" {
  description = "The Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account"
  value       = module.dataflow_controller_service_account.email
}

output "storage_writer_service_account_email" {
  description = "The Storage writer service account email. Should be used to write data to the buckets the ingestion pipeline reads from."
  value       = module.storage_writer_service_account.email
}

output "pubsub_writer_service_account_email" {
  description = "The PubSub writer service account email. Should be used to write data to the PubSub topics the ingestion pipeline reads from."
  value       = module.pubsub_writer_service_account.email
}

output "data_ingest_bucket_names" {
  description = "The name list of the buckets created for data ingest pipeline."
  value       = module.data_ingest_bucket.names_list
}

output "data_ingest_topic_name" {
  description = "The topic created for data ingest pipeline."
  value       = module.data_ingest_topic.topic
}

output "data_ingest_bigquery_dataset" {
  description = "The bigquery dataset created for data ingest pipeline."
  value       = module.bigquery_dataset.bigquery_dataset
}

output "network_name" {
  value       = module.vpc_service_controls.network_name
  description = "The name of the VPC being created"
}

output "network_self_link" {
  value       = module.vpc_service_controls.network_self_link
  description = "The URI of the VPC being created"
}

output "subnets_names" {
  value       = module.vpc_service_controls.subnets_names
  description = "The names of the subnets being created"
}

output "subnets_ips" {
  value       = module.vpc_service_controls.subnets_ips
  description = "The IPs and CIDRs of the subnets being created"
}

output "subnets_self_links" {
  value       = module.vpc_service_controls.subnets_self_links
  description = "The self-links of subnets being created"
}

output "subnets_regions" {
  value       = module.vpc_service_controls.subnets_regions
  description = "The region where the subnets will be created"
}

output "access_level_name" {
  value       = module.vpc_service_controls.access_level_name
  description = "Access context manager access level name "
}

output "service_perimeter_name" {
  value       = module.vpc_service_controls.service_perimeter_name
  description = "Access context manager service perimeter name "
}

output "project_number" {
  value       = module.vpc_service_controls.project_number
  description = "Project number included on perimeter"
}

output "cmek_keyring_full_name" {
  value       = module.cmek.keyring
  description = "The Keyring full name for the KMS Customer Managed Encryption Keys."
}

output "cmek_keyring_name" {
  value       = var.cmek_keyring_name
  description = "The Keyring name for the KMS Customer Managed Encryption Keys."
}

output "cmek_ingestion_crypto_key" {
  value       = module.cmek.keys[local.ingestion_key_name]
  description = "The Customer Managed Crypto Key for the Ingestion crypto boundary."
}

output "cmek_bigquery_crypto_key" {
  value       = module.cmek.keys[local.bigquery_key_name]
  description = "The Customer Managed Crypto Key for the BigQuery service."
}

output "default_storage_sa" {
  description = "The default Storage service account granted encrypt/decrypt permission on the KMS key."
  value       = local.storage_sa
}

output "default_pubsub_sa" {
  description = "The default Pub/Sub service account granted encrypt/decrypt permission on the KMS key."
  value       = local.pubsub_sa
}

output "default_bigquery_sa" {
  description = "The default Bigquery service account granted encrypt/decrypt permission on the KMS key."
  value       = local.bigquery_sa
}
