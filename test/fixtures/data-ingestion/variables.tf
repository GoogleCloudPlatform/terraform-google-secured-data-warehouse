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

variable "region" {
  type        = string
  description = "The region in which the subnetwork will be created."
  default     = "us-central1"
}

variable "terraform_service_account" {
  description = "Service account email of the account to impersonate to run Terraform."
  type        = string
}

variable "project_id" {
  description = "The ID of the project in which the service account will be created."
  type        = string
}

variable "vpc_name" {
  type        = string
  description = "the name of the network."
  default     = "vpc-tst-network"
}

variable "subnet_ip" {
  type        = string
  description = "The CDIR IP range of the subnetwork."
  default     = "10.0.32.0/21"
}

variable "access_context_manager_policy_id" {
  type        = number
  description = "The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format=\"value(name)\"`."
}

variable "perimeter_additional_members" {
  description = "The list additional members to be added on perimeter access. Prefix of group: user: or serviceAccount: is required."
  type        = list(string)
  default     = []
}

variable "bucket_name" {
  description = "The main part of the name of the bucket to be created."
  type        = string
  default     = "bkt-test-int"
}

variable "bucket_location" {
  description = "Bucket location."
  type        = string
  default     = "US"
}

variable "dataset_id" {
  description = "Unique ID for the dataset being provisioned."
  type        = string
  default     = "dts_test_int"
}

variable "dataset_name" {
  description = "Friendly name for the dataset being provisioned."
  type        = string
  default     = "Ingest dataset"
}

variable "dataset_description" {
  description = "Dataset description."
  type        = string
  default     = "Ingest dataset"
}

variable "dataset_location" {
  description = "The regional location for the dataset only US and EU are allowed in module"
  type        = string
  default     = "US"
}

variable "dataset_default_table_expiration_ms" {
  description = "TTL of tables using the dataset in MS. The default value is almost 12 months."
  type        = number
  default     = 31536000000
}
