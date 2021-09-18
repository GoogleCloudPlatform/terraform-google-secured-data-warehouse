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

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "storage_writer_service_account_email" {
  description = "The Storage writer service account email. Should be used to write data to the buckets the ingestion pipeline reads from."
  value       = module.data_ingestion.storage_writer_service_account_email

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "pubsub_writer_service_account_email" {
  description = "The PubSub writer service account email. Should be used to write data to the PubSub topics the ingestion pipeline reads from."
  value       = module.data_ingestion.pubsub_writer_service_account_email

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "data_ingest_bucket_names" {
  description = "The name list of the buckets created for data ingest pipeline."
  value       = module.data_ingestion.data_ingest_bucket_names

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "data_ingest_dataflow_bucket_name" {
  description = "The name of the bucket created for dataflow in the data ingest pipeline."
  value       = module.data_ingestion.data_ingest_dataflow_bucket_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "confidential_data_dataflow_bucket_name" {
  description = "The name of the bucket created for dataflow in the confidential data pipeline."
  value       = module.bigquery_sensitive_data.confidential_data_dataflow_bucket_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "data_ingest_topic_name" {
  description = "The topic created for data ingest pipeline."
  value       = module.data_ingestion.data_ingest_topic_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "data_ingest_bigquery_dataset" {
  description = "The bigquery dataset created for data ingest pipeline."
  value       = module.data_ingestion.data_ingest_bigquery_dataset

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}


output "network_name" {
  description = "The name of the VPC being created."
  value       = module.dwh_networking.network_name
}

output "network_self_link" {
  description = "The URI of the VPC being created."
  value       = module.dwh_networking.network_self_link

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "subnets_names" {
  description = "The names of the subnets being created."
  value       = module.dwh_networking.subnets_names

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "subnets_ips" {
  description = "The IPs and CIDRs of the subnets being created."
  value       = module.dwh_networking.subnets_ips

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "subnets_self_links" {
  description = "The self-links of subnets being created."
  value       = module.dwh_networking.subnets_self_links

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "confidential_subnets_self_links" {
  description = "The self-links of confidential subnets being created."
  value       = module.dwh_networking_privileged.subnets_self_links

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "subnets_regions" {
  description = "The region where the subnets will be created."
  value       = module.dwh_networking.subnets_regions

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "data_ingestion_access_level_name" {
  description = "Access context manager access level name."
  value       = module.data_ingestion_vpc_sc.access_level_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "data_ingestion_service_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = module.data_ingestion_vpc_sc.service_perimeter_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "data_governance_access_level_name" {
  description = "Access context manager access level name."
  value       = module.data_governance_vpc_sc.access_level_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "data_governance_service_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = module.data_governance_vpc_sc.service_perimeter_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "privileged_access_level_name" {
  description = "Access context manager access level name."
  value       = module.privileged_data_vpc_sc.access_level_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "privileged_service_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = module.privileged_data_vpc_sc.service_perimeter_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "cmek_keyring_full_name" {
  description = "The Keyring full name for the KMS Customer Managed Encryption Keys."
  value       = module.data_governance.cmek_keyring_full_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "cmek_keyring_name" {
  description = "The Keyring name for the KMS Customer Managed Encryption Keys."
  value       = module.data_governance.cmek_keyring_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "cmek_ingestion_crypto_key" {
  description = "The Customer Managed Crypto Key for the Ingestion crypto boundary."
  value       = module.data_governance.cmek_ingestion_crypto_key

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "cmek_bigquery_crypto_key" {
  description = "The Customer Managed Crypto Key for the BigQuery service."
  value       = module.data_governance.cmek_bigquery_crypto_key

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "cmek_reidentification_crypto_key" {
  description = "The Customer Managed Crypto Key for the Privileged crypto boundary."
  value       = module.data_governance.cmek_reidentification_crypto_key

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "cmek_confidential_bigquery_crypto_key" {
  description = "The Customer Managed Crypto Key for the confidential BigQuery service."
  value       = module.data_governance.cmek_confidential_bigquery_crypto_key

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "cmek_ingestion_crypto_key_name" {
  description = "The Customer Managed Crypto Key name for the Ingestion crypto boundary."
  value       = module.data_governance.cmek_ingestion_crypto_key_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "cmek_bigquery_crypto_key_name" {
  description = "The Customer Managed Crypto Key name for the BigQuery service."
  value       = module.data_governance.cmek_bigquery_crypto_key_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "cmek_reidentification_crypto_key_name" {
  description = "The Customer Managed Crypto Key name for the reidentification crypto boundary."
  value       = module.data_governance.cmek_reidentification_crypto_key_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "cmek_confidential_bigquery_crypto_key_name" {
  description = "The Customer Managed Crypto Key name for the confidential BigQuery service."
  value       = module.data_governance.cmek_confidential_bigquery_crypto_key_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "emails_list" {
  description = "The service account email addresses by name."
  value       = module.bigquery_sensitive_data.emails_list

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "medium_policy_taxonomy_id" {
  description = "Content for Policy Tag ID in medium policy."
  value       = module.bigquery_sensitive_data.medium_policy_taxonomy_id

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "high_policy_taxonomy_id" {
  description = "Content for Policy Tag ID in high policy."
  value       = module.bigquery_sensitive_data.high_policy_taxonomy_id

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "member_policy_ssn_confidential" {
  description = "SA member for Social Security Number policy tag."
  value       = module.bigquery_sensitive_data.member_policy_ssn_confidential
}

output "member_policy_name_confidential" {
  description = "SA member for Person Name policy tag."
  value       = module.bigquery_sensitive_data.member_policy_name_confidential

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "member_policy_name_private" {
  description = "SA member for Person Name policy tag."
  value       = module.bigquery_sensitive_data.member_policy_name_private

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "taxonomy_name" {
  description = "The taxonomy display name."
  value       = module.bigquery_sensitive_data.taxonomy_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "confidential_dataflow_controller_service_account_email" {
  description = "The confidential Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account."
  value       = module.bigquery_sensitive_data.confidential_dataflow_controller_service_account_email

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}
