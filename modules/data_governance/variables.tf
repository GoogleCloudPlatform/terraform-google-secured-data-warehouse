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
  description = "Service account email of the account to impersonate to run Terraform"
  type        = string
}

variable "dlp_tkek_keyring_name" {
  description = "Name to be used for KMS Keyring"
  type        = string
  default     = "dlp-de-identification-keyring"
}

variable "dlp_tkek_key_name" {
  description = "Name to be used for KMS Key"
  type        = string
  default     = "dlp-de-identification-crypto-key"
}

variable "template_file" {
  description = "Path to the DLP de-identification template file."
  type        = string
}

variable "template_prefix" {
  description = "Prefix of the ID of the DLP de-identification template to be created."
  type        = string
  default     = ""

}
