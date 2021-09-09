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
  description = "The Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account."
  value       = module.data_ingestion.dataflow_controller_service_account_email
}

output "storage_writer_service_account_email" {
  description = "The Storage writer service account email. Should be used to write data to the buckets the ingestion pipeline reads from."
  value       = module.data_ingestion.storage_writer_service_account_email
}

output "pubsub_writer_service_account_email" {
  description = "The PubSub writer service account email. Should be used to write data to the PubSub topics the ingestion pipeline reads from."
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

output "network_name" {
  description = "The name of the VPC being created."
  value       = module.data_ingestion.network_name
}

output "network_self_link" {
  description = "The URI of the VPC being created."
  value       = module.data_ingestion.network_self_link
}

output "subnets_names" {
  description = "The names of the subnets being created."
  value       = module.data_ingestion.subnets_names
}

output "subnets_ips" {
  description = "The IPs and CIDRs of the subnets being created."
  value       = module.data_ingestion.subnets_ips
}

output "subnets_self_links" {
  description = "The self-links of subnets being created."
  value       = module.data_ingestion.subnets_self_links
}

output "access_level_name" {
  description = "Access context manager access level name."
  value       = module.data_ingestion.access_level_name
}

output "service_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = module.data_ingestion.service_perimeter_name
}

output "cmek_keyring_full_name" {
  description = "The Keyring full name for the KMS Customer Managed Encryption Keys."
  value       = module.data_ingestion.cmek_keyring_full_name
}

output "cmek_keyring_name" {
  description = "The Keyring name for the KMS Customer Managed Encryption Keys."
  value       = module.data_ingestion.cmek_keyring_name
}

output "cmek_ingestion_crypto_key" {
  description = "The Customer Managed Crypto Key for the Ingestion crypto boundary."
  value       = module.data_ingestion.cmek_ingestion_crypto_key
}

output "cmek_bigquery_crypto_key" {
  description = "The Customer Managed Crypto Key for the BigQuery service."
  value       = module.data_ingestion.cmek_bigquery_crypto_key
}

output "logging_sinks" {
  description = "The list of sink that were created."
  value       = module.centralized_logging[0].sinks
}

output "logging_bucket_name" {
  description = "The name of the bucket that will store the exported logs."
  value       = module.centralized_logging[0].bucket_name
}
