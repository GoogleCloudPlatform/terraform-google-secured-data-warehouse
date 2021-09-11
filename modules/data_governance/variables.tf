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

variable "terraform_service_account" {
  description = "The email address of the service account that will run the Terraform code."
  type        = string
}

variable "kms_keys" {
  description = "The KMS keys that are going to be created."
  type        = list(string)
}

variable "kms_keys_encrypters_decripters_members" {
  description = "The encrypters and decripters for each key. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required."
  type        = map(list(string))
}

variable "project_id" {
  description = "The ID of the project in which the service account will be created."
  type        = string
}

variable "data_governance_project_id" {
  description = "The ID of the project in which the data governance resources will be created."
  type        = string
}

variable "datalake_project_id" {
  description = "The ID of the project in which the Bigquery will be created."
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
