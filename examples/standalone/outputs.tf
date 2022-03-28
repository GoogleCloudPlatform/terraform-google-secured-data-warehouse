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

output "centralized_logging_bucket_name" {
  description = "The name of the bucket created for storage logging."
  value       = module.centralized_logging.bucket_name
}

output "confidential_data_project_name" {
  description = "The Project where the confidential datasets and tables are created.confidential data."
  value       = module.base_projects.confidential_data_project_id

  depends_on = [
    module.secured_data_warehouse
  ]
}

output "data_ingestion_bucket_name" {
  description = "The name of the bucket created for the data ingestion pipeline."
  value       = module.secured_data_warehouse.data_ingestion_dataflow_bucket_name
}

output "data_ingestion_project_name" {
  description = "The name of the project created for the data ingstion pipeline."
  value       = module.base_projects.data_ingestion_project_id

  depends_on = [
    module.secured_data_warehouse
  ]
}

output "data_ingestion_pubsub_topic" {
  description = "The PubSub topic used for the data ingestion pipeline."
  value       = module.secured_data_warehouse.pubsub_resource_location
}

output "data_governance_project_name" {
  description = "The name of the project created for data governance."
  value       = module.secured_data_warehouse.data_governance_project_name
}

output "non_confidential_data_project_name" {
  description = "The name of the project created for non-confidential data."
  value       = module.secured_data_warehouse.non_confidential_data_project_name
}

output "pubsub_writer_service_account_email" {
  description = "The PubSub writer service account email. Should be used to write data to the PubSub topics the data ingestion pipeline reads from."
  value       = module.secured_data_warehouse.pubsub_writer_service_account_email
}

output "storage_writer_service_account_email" {
  description = "The Storage writer service account email. Should be used to write data to the buckets the data ingestion pipeline reads from."
  value       = module.secured_data_warehouse.storage_writer_service_account_email
}

output "taxonomy_display_name" {
  description = "The name of the taxonomy."
  value       = resource.secure_taxonomy.display_name
}

output "dataflow_controller_service_account_email" {
  description = "The regional de identification pipeline service account."
  value       = module.de_identification_template.dataflow_controller_service_account_email
}

output "cmek_keyring_name" {
  description = "The name of the customer manager encrypted key keyring created in standalone example."
  value       = module.secured_data_warehouse.cmek_keyring_name
}

output "tek_wrapping_key_name" {
  description = "The name of tek wrapping key"
  value       = module.tek_wrapping_key.keyring
}

output "data_ingestion_service_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = module.secured_data_warehouse.data_ingestion_service_perimeter_name
}

output "confidential_data_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = module.secured_data_warehouse.confidential_data_perimeter_name
}

output "data_governance_perimeter_name" {
  description = "Access context manager service perimeter name."
  value       = module.secured_data_warehouse.data_governance_service_perimeter_name
}

output "cmek_confidential_bigquery_crypto_key" {
  description = "The Customer Managed Crypto Key for the BigQuery service."
  value       = module.secured_data_warehouse.cmek_bigquery_crypto_key
}

output "regional_reid_pipeline_subnetwork_self_link" {
  description = "The subnetwork link created for regional re-identification pipeline."
  value       = module.regional_reid_pipeline.subnetwork_self_link
}

output "regional_deid_pipeline_subnetwork_self_link" {
  description = "The subnetwork link created for regional de-identification pipeline."
  value       = module.regional_deid_pipeline.subnetwork_self_link
}

output "confidential_data_dataflow_bucket_name" {
  description = "The name of the bucket created for dataflow in the confidential data pipeline."
  value       = module.secured_data_warehouse.confidential_data_dataflow_bucket_name
}

output "data_ingestion_dataflow_bucket_name" {
  description = "The name of the bucket created for dataflow in the data ingestion pipeline."
  value       = module.secured_data_warehouse.data_ingestion_dataflow_bucket_name
}

output "vpc_sc_bridge_confidential_data_ingestion_name" {
  description = "VPC-SC bridge between confidential data and data ingestion"
  value       = module.secured_data_warehouse.vpc_sc_bridge_confidential_data_ingestion
}

output "vpc_sc_bridge_confidential_governance_name" {
  description = "VPC-SC bridge between confidential data and data governance"
  value       = module.secured_data_warehouse.vpc_sc_bridge_confidential_governance
}

output "vpc_sc_bridge_data_ingestion_governance_name" {
  description = "VPC-SC bridge between data ingestion and data governance"
  value       = module.secured_data_warehouse.vpc_sc_bridge_data_ingestion_governance
}

output "artifact_registry_python_reader" {
  description = "All attributes of the created resource according to the mode."
  value       = module.secured_data_warehouse.google_artifact_registry_repository_iam_member.python_reader
}


output "artifact_registry_confidential_python_reader" {
  description = "All attributes of the created resource according to the mode."
  value       = module.secured_data_warehouse.google_artifact_registry_repository_iam_member.confidential_python_reader
}

output "artifact_registry_docker_reader" {
  description = "All attributes of the created resource according to the mode."
  value       = module.secured_data_warehouse.google_artifact_registry_repository_iam_member.docker_reader
}

output "artifact_registry_confidential_docker_reader" {
  description = "All attributes of the created resource according to the mode."
  value       = module.secured_data_warehouse.google_artifact_registry_repository_iam_member.confidential_docker_reader
}

output "gs_path_reid_template" {
  description = "The storage path to reid template"
  value       = module.regional_reid_pipeline.container_spec_gcs_path
}

output "gs_path_deid_template" {
  description = "The storage path to deid template"
  value       = module.regional_deid_pipeline.container_spec_gcs_path
}