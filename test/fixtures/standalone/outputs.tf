/**
 * Copyright 2022 Google LLC
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

// depends_on is necessary to ensure that the bigquery table is already created
output "bigquery_confidential_table" {
  description = "The bigquery table created for the confidential project."
  value       = module.example.bigquery_confidential_table
}

// depends_on is necessary to ensure that the bigquery table is already created
output "bigquery_non_confidential_table" {
  description = "The bigquery table created for the non confidential project."
  value       = module.example.bigquery_non_confidential_table
}

output "confidential_dataset" {
  description = "The bigquery dataset created for confidential data."
  value       = module.example.confidential_dataset
}

output "non_confidential_dataset" {
  description = "The bigquery dataset created for non-confidential data."
  value       = module.example.non_confidential_dataset
}

output "name" {
  description = "Folder name."
  value       = google_folder.folders.name
}

output "confidential_data_dataflow_bucket_name" {
  description = "The name of the bucket created for dataflow in the confidential data pipeline."
  value       = module.example.confidential_data_dataflow_bucket_name
}

output "data_ingestion_bucket_name" {
  description = "The name of the bucket created for the data ingestion pipeline."
  value       = module.example.data_ingestion_bucket_name
}

output "data_ingestion_dataflow_bucket_name" {
  description = "The name of the bucket created for dataflow in the data ingestion pipeline."
  value       = module.example.data_ingestion_dataflow_bucket_name
}

output "confidential_data_project_id" {
  description = "The ID of the project created for confidential datasets and tables."
  value       = module.example.confidential_data_project_id

}

output "data_governance_project_id" {
  description = "The ID of the project created for data governance."
  value       = module.example.data_governance_project_id

}

output "data_ingestion_project_id" {
  description = "The ID of the project created for the data ingstion pipeline."
  value       = module.example.data_ingestion_project_id

}

output "non_confidential_data_project_id" {
  description = "The id of the project created for non-confidential data."
  value       = module.example.non_confidential_data_project_id

}

output "data_ingestion_topic_name" {
  description = "The topic created for data ingestion pipeline."
  value       = module.example.data_ingestion_topic_name

}
