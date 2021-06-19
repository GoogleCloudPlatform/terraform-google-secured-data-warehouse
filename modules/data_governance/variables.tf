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

variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "terraform_service_account" {
  description = "Service account email of the account to impersonate to run Terraform."
  type        = string
}

variable "kms_location" {
  description = "The location of KMS resources. See https://cloud.google.com/dlp/docs/locations for a list of locations that can be used for both KMS and DLP. The 'global' KMS location is valid."
  type        = string
}

variable "dlp_tkek_keyring_name" {
  description = "Name to be used for KMS Keyring."
  type        = string
  default     = "dlp-de-identification-keyring"
}

variable "dlp_tkek_key_name" {
  description = "Name to be used for KMS Key."
  type        = string
  default     = "dlp-de-identification-crypto-key"
}

variable "original_key_secret_name" {
  description = "Name of the secret used to hold a user provided key for encryption."
  type        = string
}

variable "project_id_secret_mgr" {
  description = "ID of the project that hosts the Secret Manager service being used."
  type        = string
}

variable "template_file" {
  description = "Path to the DLP de-identification template file."
  type        = string
}

variable "template_id_prefix" {
  description = "Prefix of the ID of the DLP de-identification template to be created."
  type        = string
  default     = ""
}

variable "template_display_name" {
  description = "Display name of the DLP de-identification template."
  type        = string
  default     = "KMS Wrapped crypto Key de-identification"
}

variable "template_description" {
  description = "Description of the DLP de-identification template."
  type        = string
  default     = "De-identifies sensitive content defined in the template with a KMS Wrapped crypto Key."
}
