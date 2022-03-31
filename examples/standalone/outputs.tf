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
  value       = local.bigquery_confidential_table

  depends_on = [
    module.regional_reid_pipeline
  ]
}

// depends_on is necessary to ensure that the bigquery table is already created
output "bigquery_non_confidential_table" {
  description = "The bigquery table created for the non confidential project."
  value       = local.bigquery_non_confidential_table

  depends_on = [
    module.regional_deid_pipeline
  ]
}

output "blueprint_type" {
  description = "Type of blueprint this module represents."
  value       = module.secured_data_warehouse.blueprint_type
}

output "cmek_bigquery_crypto_key" {
  description = "The Customer Managed Crypto Key for the BigQuery service."
  value       = module.secured_data_warehouse.cmek_bigquery_crypto_key
}

output "cmek_confidential_bigquery_crypto_key" {
  description = "The Customer Managed Crypto Key for the confidential BigQuery service."
  value       = module.secured_data_warehouse.cmek_confidential_bigquery_crypto_key
}

output "cmek_data_ingestion_crypto_key" {
  description = "The Customer Managed Crypto Key for the data ingestion crypto boundary."
  value       = module.secured_data_warehouse.cmek_data_ingestion_crypto_key
}

output "cmek_reidentification_crypto_key" {
  description = "The Customer Managed Crypto Key for the reidentification crypto boundary."
  value       = module.secured_data_warehouse.cmek_reidentification_crypto_key
}

output "tek_wrapping_keyring" {
  description = "The name of tek wrapping key"
  value       = module.tek_wrapping_key.keyring
}

output "centralized_logging_bucket_name" {
  description = "The name of the bucket created for storage logging."
  value       = module.centralized_logging.bucket_name
}

output "confidential_data_dataflow_bucket_name" {
  description = "The name of the bucket created for dataflow in the confidential data pipeline."
  value       = module.secured_data_warehouse.confidential_data_dataflow_bucket_name
}

output "data_ingestion_bucket_name" {
  description = "The name of the bucket created for the data ingestion pipeline."
  value       = module.secured_data_warehouse.data_ingestion_dataflow_bucket_name
}

output "data_ingestion_dataflow_bucket_name" {
  description = "The name of the bucket created for dataflow in the data ingestion pipeline."
  value       = module.secured_data_warehouse.data_ingestion_dataflow_bucket_name
}

output "confidential_data_project_id" {
  description = "The Project where the confidential datasets and tables are created."
  value       = module.base_projects.confidential_data_project_id

}

output "data_governance_project_id" {
  description = "The id of the project created for data governance."
  value       = module.base_projects.data_governance_project_id

}

output "data_ingestion_project_id" {
  description = "The id of the project created for the data ingstion pipeline."
  value       = module.base_projects.data_ingestion_project_id

}

output "non_confidential_data_project_id" {
  description = "The id of the project created for non-confidential data."
  value       = module.base_projects.non_confidential_data_project_id

}

output "template_project_id" {
  description = "The id of the flex template created."
  value       = module.template_project.project_id
}

output "data_ingestion_topic_name" {
  description = "The topic created for data ingestion pipeline."
  value       = module.secured_data_warehouse.data_ingestion_topic_name

}

output "pubsub_writer_service_account_email" {
  description = "The PubSub writer service account email. Should be used to write data to the PubSub topics the data ingestion pipeline reads from."
  value       = module.secured_data_warehouse.pubsub_writer_service_account_email
}

output "dataflow_controller_service_account_email" {
  description = "The regional de identification pipeline service account."
  value       = module.secured_data_warehouse.dataflow_controller_service_account_email
}

output "storage_writer_service_account_email" {
  description = "The Storage writer service account email. Should be used to write data to the buckets the data ingestion pipeline reads from."
  value       = module.secured_data_warehouse.storage_writer_service_account_email
}

output "confidential_data_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = module.secured_data_warehouse.confidential_service_perimeter_name
}

output "data_governance_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = module.secured_data_warehouse.data_governance_service_perimeter_name
}

output "data_ingestion_service_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = module.secured_data_warehouse.data_ingestion_service_perimeter_name
}

output "confidential_network_name" {
  description = "The name of the confidential VPC being created."
  value       = module.base_projects.confidential_network_name
}

output "confidential_network_self_link" {
  description = "The URI of the confidential VPC being created."
  value       = module.base_projects.confidential_network_self_link
}

output "confidential_subnets_self_link" {
  description = "The self-links of confidential subnets being created."
  value       = module.base_projects.confidential_subnets_self_link
}

output "data_ingestion_network_name" {
  description = "The name of the data ingestion VPC being created."
  value       = module.base_projects.data_ingestion_network_name
}

output "data_ingestion_network_self_link" {
  description = "The URI of the data ingestion VPC being created."
  value       = module.base_projects.data_ingestion_network_self_link
}

output "data_ingestion_subnets_self_link" {
  description = "The self-links of data ingestion subnets being created."
  value       = module.base_projects.data_ingestion_subnets_self_link
}

output "taxonomy_display_name" {
  description = "The name of the taxonomy."
  value       = google_data_catalog_taxonomy.secure_taxonomy.display_name
}
