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

output "keyring" {
  description = "The name of the keyring."
  value       = module.kms_dlp_tkek.keyring_resource.name
}

output "location" {
  description = "The location of the keyring."
  value       = module.kms_dlp_tkek.keyring_resource.location
}

output "keys" {
  description = "List of created key names."
  value       = keys(module.kms_dlp_tkek.keys)
}

output "template_id" {
  description = "ID of the DLP de-identification template created."
  value       = local.template_id
}
