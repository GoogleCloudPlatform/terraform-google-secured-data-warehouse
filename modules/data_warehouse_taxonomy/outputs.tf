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
  value       = module.service_accounts.emails
}

output "medium_policy_taxonomy_id" {
  description = "Content for Policy Tag ID in medium policy."
  value       = google_data_catalog_policy_tag.name_child_policy_tag.id
}

output "high_policy_taxonomy_id" {
  description = "Content for Policy Tag ID in high policy."
  value       = google_data_catalog_policy_tag.ssn_child_policy_tag.id
}

output "member_policy_ssn_confidential" {
  description = "SA member for Social Security Number policy tag."
  value       = [for m in google_data_catalog_policy_tag_iam_member.confidential_sa_ssn : m.member]
}

output "member_policy_name_confidential" {
  description = "SA member for Person Name policy tag."
  value       = [for m in google_data_catalog_policy_tag_iam_member.confidential_sa_name : m.member]
}

output "member_policy_name_private" {
  description = "SA member for Person Name policy tag."
  value       = [for m in google_data_catalog_policy_tag_iam_member.private_sa_name : m.member]
}

output "taxonomy_name" {
  description = "The taxonomy display name."
  value       = google_data_catalog_taxonomy.secure_taxonomy.display_name
}

output "confidential_dataflow_controller_service_account_email" {
  description = "The confidential Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account."
  value       = module.dataflow_controller_service_account.email
}
