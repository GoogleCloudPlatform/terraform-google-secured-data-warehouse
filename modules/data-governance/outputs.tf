/**
 * Copyright 2022 Google LLC
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

output "cmek_keyring_full_name" {
  description = "The Keyring full name for the KMS Customer Managed Encryption Keys."
  value       = module.cmek.keyring
}

output "cmek_keyring_name" {
  description = "The Keyring name for the KMS Customer Managed Encryption Keys."
  value       = module.cmek.keyring_name
}

output "cmek_data_ingestion_crypto_key" {
  description = "The Customer Managed Crypto Key for the data ingestion crypto boundary."
  value       = module.cmek.keys[local.data_ingestion_key_name]
}

output "cmek_bigquery_crypto_key" {
  description = "The Customer Managed Crypto Key for the BigQuery service."
  value       = module.cmek.keys[local.bigquery_key_name]
}

output "cmek_reidentification_crypto_key" {
  description = "The Customer Managed Crypto Key for the reidentification crypto boundary."
  value       = module.cmek.keys[local.reidentification_key_name]
}

output "cmek_confidential_bigquery_crypto_key" {
  description = "The Customer Managed Crypto Key for the confidential BigQuery service."
  value       = module.cmek.keys[local.confidential_bigquery_key_name]
}

output "cmek_data_ingestion_crypto_key_name" {
  description = "The Customer Managed Crypto Key name for the data ingestion crypto boundary."
  value       = local.data_ingestion_key_name
}

output "cmek_bigquery_crypto_key_name" {
  description = "The Customer Managed Crypto Key name for the BigQuery service."
  value       = local.bigquery_key_name
}

output "cmek_reidentification_crypto_key_name" {
  description = "The Customer Managed Crypto Key name for the reidentification crypto boundary."
  value       = local.reidentification_key_name
}

output "cmek_confidential_bigquery_crypto_key_name" {
  description = "The Customer Managed Crypto Key name for the confidential BigQuery service."
  value       = local.confidential_bigquery_key_name
}
