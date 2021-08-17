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
  description = "The project's ID"
  value       = var.project_id
}

output "df_job_state" {
  description = "The state of the newly created Dataflow job"
  value       = module.dataflow_job.state
}

output "df_job_id" {
  description = "The unique Id of the newly created Dataflow job"
  value       = module.dataflow_job.id
}

output "df_job_name" {
  description = "The name of the newly created Dataflow job"
  value       = module.dataflow_job.name
}

output "df_job_region" {
  description = "The region of the newly created Dataflow job."
  value       = module.dataflow_job.name
}

output "controller_service_account" {
  description = "The Service Account email that will be used to identify the VMs in which the jobs are running"
  value       = module.data_ingestion.dataflow_controller_service_account_email
}

output "bucket_tmp_name" {
  description = "The name of the bucket"
  value       = module.dataflow_tmp_bucket.bucket.name
}

output "bucket_ingestion_name" {
  description = "The name of the bucket"
  value       = module.data_ingestion.data_ingest_bucket_names[0]
}

output "dlp_location" {
  description = "The location of the DLP resources."
  value       = module.de_identification_template.dlp_location
}

output "template_id" {
  description = "The ID of the Cloud DLP de-identification template that is created."
  value       = module.de_identification_template.template_id
}
