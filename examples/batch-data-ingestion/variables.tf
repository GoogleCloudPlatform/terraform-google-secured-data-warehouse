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

variable "project_id" {
  description = "The ID of the project in which the service account will be created."
  type        = string
}

variable "bucket_location" {
  description = "Bucket location."
  type        = string
  default     = "US"
}
variable "data_ingestion_bucket" {
  description = "The bucket name where the files for ingestion is located."
  type        = string
}

variable "terraform_service_account" {
  description = "Service account email of the account to impersonate to run Terraform."
  type        = string
}

variable "dataflow_service_account" {
  description = "The Service Account email that will be used to identify the VMs in which the jobs are running"
  type        = string
}

variable "dataset_id" {
  description = "Unique ID for the dataset being provisioned."
  type        = string
  default     = "dts_test_int"
}

variable "table_name" {
  description = "Unique ID for the table in dataset being provisioned."
  type        = string
  default     = "table_test_int"
}

variable "subnetwork_self_link" {
  description = "The subnetwork self link to which VMs will be assigned."
  type        = string
}

variable "network_self_link" {
  type        = string
  description = "The network self link to which VMs will be assigned."
}

variable "crypto_key" {
  description = "The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP."
  type        = string
}

variable "bucket_force_destroy" {
  description = "When deleting a bucket, this boolean option will delete all contained objects. If you try to delete a bucket that contains objects, Terraform will fail that run."
  type        = bool
  default     = false
}
