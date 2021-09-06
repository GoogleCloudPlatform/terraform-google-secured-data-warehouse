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

output "data_governance_project_id" {
  description = "The project_id used to create infra."
  value       = var.data_governance_project_id
}

output "de_identification_template_dlp_location" {
  description = "The location of the DLP resources."
  value       = module.de_identification_template.dlp_location
}

output "de_identification_template_crypto_key" {
  description = "The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP."
  value       = module.de_identification_template.crypto_key
}

output "de_identification_template_wrapped_key" {
  description = "The base64 encoded data crypto key wrapped by KMS."
  value       = module.de_identification_template.wrapped_key
}

output "de_identification_template_template_id" {
  description = "The ID of the Cloud DLP de-identification template that is created."
  value       = module.de_identification_template.template_id
}

output "template_display_name" {
  description = "Display name of the DLP de-identification template."
  value       = module.de_identification_template.template_display_name
}

output "template_description" {
  description = "Description of the DLP de-identification template."
  value       = module.de_identification_template.template_description
}
