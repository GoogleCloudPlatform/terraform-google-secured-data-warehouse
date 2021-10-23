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
  value       = module.landing_zone.dataflow_controller_service_account_email

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
  description = "The Storage writer service account email. Should be used to write data to the buckets the landing zone pipeline reads from."
  value       = module.landing_zone.storage_writer_service_account_email
}

output "pubsub_writer_service_account_email" {
  description = "The PubSub writer service account email. Should be used to write data to the PubSub topics the landing zone pipeline reads from."
  value       = module.landing_zone.pubsub_writer_service_account_email
}

output "landing_zone_bucket_name" {
  description = "The name of the bucket created for landing zone pipeline."
  value       = module.landing_zone.landing_zone_bucket_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "landing_zone_dataflow_bucket_name" {
  description = "The name of the bucket created for dataflow in the landing zone pipeline."
  value       = module.landing_zone.landing_zone_dataflow_bucket_name

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

output "landing_zone_topic_name" {
  description = "The topic created for landing zone pipeline."
  value       = module.landing_zone.landing_zone_topic_name

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "landing_zone_bigquery_dataset" {
  description = "The bigquery dataset created for landing zone pipeline."
  value       = module.landing_zone.landing_zone_bigquery_dataset

  depends_on = [
    time_sleep.wait_for_bridge_propagation
  ]
}

output "landing_zone_access_level_name" {
  description = "Access context manager access level name."
  value       = module.landing_zone_vpc_sc.access_level_name
}

output "landing_zone_service_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = module.landing_zone_vpc_sc.service_perimeter_name
}

output "data_governance_access_level_name" {
  description = "Access context manager access level name."
  value       = module.data_governance_vpc_sc.access_level_name
}

output "data_governance_service_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = module.data_governance_vpc_sc.service_perimeter_name
}

output "confidential_access_level_name" {
  description = "Access context manager access level name."
  value       = module.confidential_data_vpc_sc.access_level_name
}

output "confidential_service_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = module.confidential_data_vpc_sc.service_perimeter_name
}

output "cmek_landing_zone_crypto_key" {
  description = "The Customer Managed Crypto Key for the landing zone crypto boundary."
  value       = module.data_governance.cmek_landing_zone_crypto_key

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
