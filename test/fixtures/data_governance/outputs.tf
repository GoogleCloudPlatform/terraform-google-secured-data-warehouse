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

output "data_governance_keyring" {
  description = "The name of the keyring."
  value       = module.data_governance.keyring
}

output "data_governance_location" {
  description = "The location of the keyring."
  value       = module.data_governance.location
}

output "data_governance_key" {
  description = "Created key name."
  value       = module.data_governance.keys[0]
}

output "data_governance_template_id" {
  description = "ID of the DLP de-identification template created."
  value       = module.data_governance.template_id
}
