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

output "dataflow_controller_service_account_email" {
  description = "The service account email."
  value       = module.dataflow_controller_service_account.email
}

output "storage_writer_service_account_email" {
  description = "The service account email."
  value       = module.storage_writer_service_account.email
}

output "pubsub_writer_service_account_email" {
  description = "The service account email."
  value       = module.pubsub_writer_service_account.email
}

output "data_ingest_bucket_names" {
  description = "The name list of the buckets created for data ingest pipeline."
  value       = module.data_ingest_bucket.names_list
}

output "data_ingest_topic_name" {
  description = "The topic created for data ingest pipeline."
  value       = module.data_ingest_topic.topic
}

output "data_ingest_bigquery_dataset" {
  description = "The bigquery dataset created for data ingest pipeline."
  value       = module.bigquery_dataset.bigquery_dataset
}

output "network_name" {
  value       = module.vpc_service_controls.network_name
  description = "The name of the VPC being created"
}

output "network_self_link" {
  value       = module.vpc_service_controls.network_self_link
  description = "The URI of the VPC being created"
}

output "subnets_names" {
  value       = module.vpc_service_controls.subnets_names
  description = "The names of the subnets being created"
}

output "subnets_ips" {
  value       = module.vpc_service_controls.subnets_ips
  description = "The IPs and CIDRs of the subnets being created"
}

output "subnets_self_links" {
  value       = module.vpc_service_controls.subnets_self_links
  description = "The self-links of subnets being created"
}

output "subnets_regions" {
  value       = module.vpc_service_controls.subnets_regions
  description = "The region where the subnets will be created"
}

output "access_level_name" {
  value       = module.vpc_service_controls.access_level_name
  description = "Access context manager access level name "
}

output "service_perimeter_name" {
  value       = module.vpc_service_controls.service_perimeter_name
  description = "Access context manager service perimeter name "
}

output "project_number" {
  value       = module.vpc_service_controls.project_number
  description = "Project number included on perimeter"
}
