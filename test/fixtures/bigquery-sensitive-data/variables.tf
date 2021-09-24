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

variable "data_ingestion_project_id" {
  description = "The ID of the project in which the data ingestion resources will be created."
  type        = string
}

variable "data_governance_project_id" {
  description = "The ID of the project in which the data governance resources will be created."
  type        = string
}

variable "privileged_data_project_id" {
  description = "Project where the privileged datasets and tables are created."
  type        = string
}

variable "datalake_project_id" {
  description = "The project ID of the BigQuery source that has de-identified data."
  type        = string
}

variable "external_flex_template_project_id" {
  description = "Project id of the external project that host the flex Dataflow templates."
  type        = string
}

variable "sdx_project_number" {
  description = "The Project Number to configure Secure data exchange with egress rule for the dataflow templates."
  type        = string
}

variable "terraform_service_account" {
  description = "The email address of the service account that will run the Terraform config."
  type        = string
}

variable "python_re_identify_template_gs_path" {
  description = "The Google Cloud Storage gs path to the JSON file built flex template that supports DLP re-identification."
  type        = string
  default     = ""
}

variable "privileged_network_self_link" {
  description = "The URI of the network where Dataflow is going to be deployed."
  type        = string
}

variable "privileged_subnets_self_link" {
  description = "The URI of the subnetwork where Dataflow is going to be deployed."
  type        = string
}

variable "perimeter_additional_members" {
  description = "The list of the additional members to be added on perimeter access. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required."
  type        = list(string)
  default     = []
}
