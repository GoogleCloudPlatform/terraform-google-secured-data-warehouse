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

output "emails_list" {
  description = "The service account email addresses by name."
  value       = module.bigquery_sensitive_data.emails_list
}

output "person_name_policy_tag" {
  description = "Content for Policy Tag ID in medium policy."
  value       = module.bigquery_sensitive_data.medium_policy_taxonomy_id
}

output "social_security_number_policy_tag" {
  description = "Content for Policy Tag ID in high policy."
  value       = module.bigquery_sensitive_data.high_policy_taxonomy_id
}

output "member_policy_ssn_confidential" {
  description = "SA member for Social Security Number policy tag confidential."
  value       = module.bigquery_sensitive_data.member_policy_ssn_confidential
}

output "member_policy_name_confidential" {
  description = "SA member for Person Name policy tag confidential."
  value       = module.bigquery_sensitive_data.member_policy_name_confidential
}

output "member_policy_name_private" {
  description = "SA member for Person Name policy tag private."
  value       = module.bigquery_sensitive_data.member_policy_name_private
}

output "bigquery_project_id" {
  description = "Project where bigquery and table were created."
  value       = var.bigquery_project_id
}

output "taxonomy_project_id" {
  description = "Project where taxonomy was created."
  value       = var.taxonomy_project_id
}

output "taxonomy_name" {
  description = "The taxonomy display name."
  value       = module.bigquery_sensitive_data.taxonomy_name
}
