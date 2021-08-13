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
  value       = module.data_ingestion.dataflow_controller_service_account_email
  description = "The Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account"
}

output "storage_writer_service_account_email" {
  value       = module.data_ingestion.storage_writer_service_account_email
  description = "The Storage writer service account email. Should be used to write data to the buckets the ingestion pipeline reads from."
}

output "pubsub_writer_service_account_email" {
  value       = module.data_ingestion.pubsub_writer_service_account_email
  description = "The PubSub writer service account email. Should be used to write data to the PubSub topics the ingestion pipeline reads from."
}

output "data_ingest_bucket_names" {
  value       = module.data_ingestion.data_ingest_bucket_names
  description = "The name list of the buckets created for data ingest pipeline."
}

output "data_ingest_topic_name" {
  value       = module.data_ingestion.data_ingest_topic_name
  description = "The topic created for data ingest pipeline."
}

output "data_ingest_bigquery_dataset" {
  value       = module.data_ingestion.data_ingest_bigquery_dataset
  description = "The bigquery dataset created for data ingest pipeline."
}

output "network_name" {
  value       = module.data_ingestion.network_name
  description = "The name of the VPC being created"
}

output "network_self_link" {
  value       = module.data_ingestion.network_self_link
  description = "The URI of the VPC being created"
}

output "subnets_names" {
  value       = module.data_ingestion.subnets_names
  description = "The names of the subnets being created"
}

output "subnets_ips" {
  value       = module.data_ingestion.subnets_ips
  description = "The IPs and CIDRs of the subnets being created"
}

output "subnets_self_links" {
  value       = module.data_ingestion.subnets_self_links
  description = "The self-links of subnets being created"
}

output "access_level_name" {
  value       = module.data_ingestion.access_level_name
  description = "Access context manager access level name "
}

output "service_perimeter_name" {
  value       = module.data_ingestion.service_perimeter_name
  description = "Access context manager service perimeter name "
}

output "cmek_keyring_full_name" {
  value       = module.data_ingestion.cmek_keyring_full_name
  description = "The Keyring full name for the KMS Customer Managed Encryption Keys."
}

output "cmek_keyring_name" {
  value       = module.data_ingestion.cmek_keyring_name
  description = "The Keyring name for the KMS Customer Managed Encryption Keys."
}

output "cmek_ingestion_crypto_key" {
  value       = module.data_ingestion.cmek_ingestion_crypto_key
  description = "The Customer Managed Crypto Key for the Ingestion crypto boundary."
}

output "cmek_bigquery_crypto_key" {
  value       = module.data_ingestion.cmek_bigquery_crypto_key
  description = "The Customer Managed Crypto Key for the BigQuery service."
}
