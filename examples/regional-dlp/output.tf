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

output "dataflow_bucket_name" {
  description = "The name of the bucket created to store Dataflow temporary data."
  value       = module.dataflow_bucket.bucket.name
}

output "templates_bucket_name" {
  description = "The name of the bucket created to store the flex template."
  value       = module.flex_dlp_template.templates_bucket_name
}

output "dataflow_controller_service_account_email" {
  description = "The Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account"
  value       = module.data_ingestion.dataflow_controller_service_account_email
}
