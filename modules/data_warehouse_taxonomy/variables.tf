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
  default     = null
}

variable "dataset_labels" {
  description = "Key value pairs in a map for dataset labels."
  type        = map(string)
  default     = {}
}

variable "confidential_access_members" {
  description = "List of members in the standard GCP form: user:{email}, serviceAccount:{email}, group:{email} who will have access to confidential information in BigQuery."
  type        = list(string)
  default     = []
}

variable "private_access_members" {
  description = "List of members in the standard GCP form: user:{email}, serviceAccount:{email}, group:{email} who will have access to private information in BigQuery."
  type        = list(string)
  default     = []
}

variable "project_roles" {
  description = "Common roles to apply to all service accounts in the project."
  type        = list(string)
  default     = []
}

variable "taxonomy_project_id" {
  description = "Project where the taxonomy is going to be created."
  type        = string
}

variable "privileged_data_project_id" {
  description = "Project where the privileged datasets and tables are created."
  type        = string
}

variable "non_sensitive_project_id" {
  description = "Project with the de-identified dataset and table."
  type        = string
}

variable "dataset_id" {
  description = "The dataset ID to deploy to data warehouse."
  type        = string
}

variable "table_id" {
  description = "The table ID to deploy to data warehouse."
  type        = string
}

variable "location" {
  description = "Default region to create resources where applicable."
  type        = string
}

variable "taxonomy_name" {
  description = "The taxonomy display name."
  type        = string
}

variable "cmek_location" {
  description = "The location for the KMS Customer Managed Encryption Keys."
  type        = string
}

variable "cmek_keyring_name" {
  description = "The Keyring name for the KMS Customer Managed Encryption Keys."
  type        = string
}
