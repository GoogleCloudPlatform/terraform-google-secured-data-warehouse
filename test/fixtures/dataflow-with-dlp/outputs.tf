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
  description = "The project's ID."
  value       = var.data_ingestion_project_id
}

output "df_job_controller_service_account" {
  description = "The email of the service account used for create Dataflow job."
  value       = module.dataflow_with_dlp.controller_service_account
}

output "df_job_network" {
  description = "The name of the network used for create Dataflow job."
  value       = module.dataflow_with_dlp.df_job_network
}

output "df_job_subnetwork" {
  description = "The name of the subnetwork used for create Dataflow job."
  value       = module.dataflow_with_dlp.df_job_subnetwork
}

output "bucket_ingestion_name" {
  description = "The name of the bucket."
  value       = module.dataflow_with_dlp.bucket_ingestion_name
}
