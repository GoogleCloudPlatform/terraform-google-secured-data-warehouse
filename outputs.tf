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

output "confidential_dataflow_controller_service_account_email" {
  description = "The confidential Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account."
  value       = module.bigquery_confidential_data.confidential_dataflow_controller_service_account_email

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "storage_writer_service_account_email" {
  description = "The Storage writer service account email. Should be used to write data to the buckets the data ingestion pipeline reads from."
  value       = module.data_ingestion.storage_writer_service_account_email
}

output "pubsub_writer_service_account_email" {
  description = "The PubSub writer service account email. Should be used to write data to the PubSub topics the data ingestion pipeline reads from."
  value       = module.data_ingestion.pubsub_writer_service_account_email
}

output "data_ingestion_bucket_name" {
  description = "The name of the bucket created for data ingestion pipeline."
  value       = module.data_ingestion.data_ingestion_bucket_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "data_ingestion_dataflow_bucket_name" {
  description = "The name of the bucket created for dataflow in the data ingestion pipeline."
  value       = module.data_ingestion.data_ingestion_dataflow_bucket_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "confidential_data_dataflow_bucket_name" {
  description = "The name of the bucket created for dataflow in the confidential data pipeline."
  value       = module.bigquery_confidential_data.confidential_data_dataflow_bucket_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "data_ingestion_topic_name" {
  description = "The topic created for data ingestion pipeline."
  value       = module.data_ingestion.data_ingestion_topic_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "data_ingestion_bigquery_dataset" {
  description = "The bigquery dataset created for data ingestion pipeline."
  value       = module.data_ingestion.data_ingestion_bigquery_dataset

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "data_ingestion_access_level_name" {
  description = "Access context manager access level name."
  value       = var.data_ingestion_perimeter == "" ? module.data_ingestion_vpc_sc[0].access_level_name : ""
}

output "data_ingestion_service_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = var.data_ingestion_perimeter == "" ? module.data_ingestion_vpc_sc[0].service_perimeter_name : ""
}

output "data_governance_access_level_name" {
  description = "Access context manager access level name."
  value       = var.data_governance_perimeter == "" ? module.data_governance_vpc_sc[0].access_level_name : ""
}

output "data_governance_service_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = var.data_governance_perimeter == "" ? module.data_governance_vpc_sc[0].service_perimeter_name : ""
}

output "confidential_access_level_name" {
  description = "Access context manager access level name."
  value       = var.confidential_data_perimeter == "" ? module.confidential_data_vpc_sc[0].access_level_name : ""
}

output "confidential_service_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = var.confidential_data_perimeter == "" ? module.confidential_data_vpc_sc[0].service_perimeter_name : ""
}

output "cmek_data_ingestion_crypto_key" {
  description = "The Customer Managed Crypto Key for the data ingestion crypto boundary."
  value       = module.data_governance.cmek_data_ingestion_crypto_key

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
  description = "The Customer Managed Crypto Key for the Confidential crypto boundary."
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

output "blueprint_type" {
  description = "Type of blueprint this module represents."
  value       = local.blueprint_type
}
