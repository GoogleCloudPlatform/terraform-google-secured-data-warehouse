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

variable "org_id" {
  description = "GCP Organization ID."
  type        = string
}

variable "access_context_manager_policy_id" {
  description = "The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format=\"value(name)\"`."
  type        = number
}

variable "data_governance_project_id" {
  description = "The ID of the project in which the data governance resources will be created."
  type        = string
}

variable "data_ingestion_project_id" {
  description = "The ID of the project in which the data ingestion resources will be created."
  type        = string
}

variable "confidential_subnets_self_link" {
  description = "The URI of the subnetwork where Data Ingestion Dataflow is going to be deployed."
  type        = string
}

variable "data_ingestion_subnets_self_link" {
  description = "The URI of the subnetwork where Data Ingestion Dataflow is going to be deployed."
  type        = string
}

variable "confidential_data_project_id" {
  description = "Project where the confidential datasets and tables are created."
  type        = string
}

variable "external_flex_template_project_id" {
  description = "Project id of the external project that host the flex Dataflow templates."
  type        = string
}

variable "sdx_project_number" {
  description = "The Project Number to configure Secure data exchange with egress rule for the flex Dataflow templates."
  type        = string
}

variable "non_confidential_project_id" {
  description = "Project with the de-identified dataset and table."
  type        = string
}

variable "crypto_key" {
  description = "The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP."
  type        = string
}

variable "wrapped_key" {
  description = "The base64 encoded data crypto key wrapped by KMS."
  type        = string
}

variable "terraform_service_account" {
  description = "The email address of the service account that will run the Terraform config."
  type        = string
}

variable "java_de_identify_template_gs_path" {
  description = "The Google Cloud Storage gs path to the JSON file built flex template that supports DLP de-identification."
  type        = string
}

variable "java_re_identify_template_gs_path" {
  description = "The Google Cloud Storage gs path to the JSON file built flex template that supports DLP re-identification."
  type        = string
}

variable "perimeter_additional_members" {
  description = "The list of all members to be added on perimeter access, except the service accounts created by this module. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required."
  type        = list(string)
}

variable "delete_contents_on_destroy" {
  description = "(Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present."
  type        = bool
  default     = false
}

variable "taxonomy_name" {
  description = "The taxonomy display name."
  type        = string
  default     = "secured_taxonomy"
}
