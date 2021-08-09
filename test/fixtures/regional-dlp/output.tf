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
  value = var.project_id
}

output "terraform_service_account" {
  value = var.terraform_service_account
}

output "dataflow_bucket_name" {
  value       = module.regional_dlp_example.dataflow_bucket_name
  description = "The name of the bucket created to store Dataflow temporary data."
}

output "cloud_build_logs_bucket_name" {
  value       = module.regional_dlp_example.cloud_build_logs_bucket_name
  description = "The name of the bucket created to store the Cloud Build logs."
}

output "templates_bucket_name" {
  value       = module.regional_dlp_example.templates_bucket_name
  description = "The name of the bucket created to store the flex template."
}

output "dataflow_controller_service_account_email" {
  description = "The Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account"
  value       = module.regional_dlp_example.dataflow_controller_service_account_email
}