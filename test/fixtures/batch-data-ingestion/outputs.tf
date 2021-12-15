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
  value       = var.data_ingestion_project_id[0]
}

output "scheduler_id" {
  description = "Cloud Scheduler Job id created."
  value       = module.batch_dataflow.scheduler_id
}

output "df_job_controller_service_account" {
  description = "The email of the service account used for create Dataflow job."
  value       = module.batch_dataflow.controller_service_account
}

output "df_job_network" {
  description = "The name of the network used for create Dataflow job."
  value       = module.batch_dataflow.df_job_network
}

output "df_job_subnetwork" {
  description = "The name of the subnetwork used for create Dataflow job."
  value       = module.batch_dataflow.df_job_subnetwork
}

output "dataflow_temp_bucket_name" {
  description = "The name of the dataflow temporary bucket."
  value       = module.batch_dataflow.dataflow_temp_bucket_name
}
