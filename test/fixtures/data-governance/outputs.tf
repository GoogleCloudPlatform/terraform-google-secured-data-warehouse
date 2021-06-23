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

output "project_id" {
  description = "The project_id used to create infra."
  value       = var.project_id
}

output "data_governance_dlp_location" {
  description = "The location of the DLP resources."
  value       = module.data_governance.dlp_location
}

output "data_governance_crypto_key" {
  description = "The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP."
  value       = module.data_governance.crypto_key
}

output "data_governance_wrapped_key" {
  description = "The base64 encoded data crypto key wrapped by KMS."
  value       = module.data_governance.wrapped_key
}

output "data_governance_template_id" {
  description = "The ID of the Cloud DLP de-identification template that is created."
  value       = module.data_governance.template_id
}

output "template_display_name" {
  description = "Display name of the DLP de-identification template."
  value       = module.data_governance.template_display_name
}

output "template_description" {
  description = "Description of the DLP de-identification template."
  value       = module.data_governance.template_description
}
