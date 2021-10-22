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

variable "delete_contents_on_destroy" {
  description = "(Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present."
  type        = bool
  default     = false
}

variable "dataset_labels" {
  description = "Key value pairs in a map for dataset labels."
  type        = map(string)
  default     = {}
}

variable "data_governance_project_id" {
  description = "The ID of the project in which the KMS, Datacatalog, and DLP resources are created."
  type        = string
}

variable "confidential_data_project_id" {
  description = "Project where the confidential datasets and tables are created."
  type        = string
}

variable "non_confidential_data_project_id" {
  description = "Project with the de-identified dataset and table."
  type        = string
}

variable "dataset_id" {
  description = "The dataset ID to deploy to data warehouse."
  type        = string
}

variable "location" {
  description = "Default region to create resources where applicable."
  type        = string
}

variable "cmek_confidential_bigquery_crypto_key" {
  description = "The Customer Managed Crypto Key for the confidential BigQuery service."
  type        = string
}

variable "cmek_reidentification_crypto_key" {
  description = "The Customer Managed Crypto Key for the reidentification crypto boundary."
  type        = string
}

variable "dataset_default_table_expiration_ms" {
  description = "TTL of tables using the dataset in MS. The default value is null."
  type        = number
  default     = null
}

variable "key_rotation_period_seconds" {
  description = "Rotation period for keys. The default value is 30 days."
  type        = string
  default     = "2592000s"
}
