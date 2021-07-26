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

variable "terraform_service_account" {
  description = "Service account email of the account to impersonate to run Terraform."
  type        = string
}

variable "dataflow_service_account" {
  type        = string
  description = "The Service Account email that will be used to identify the VMs in which the jobs are running"
}

variable "subnetwork_self_link" {
  type        = string
  description = "The subnetwork self link to which VMs will be assigned."
}

variable "network_self_link" {
  type        = string
  description = "The network self link to which VMs will be assigned."
}

variable "crypto_key" {
  description = "The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP."
  type        = string
}

variable "wrapped_key" {
  description = "The base64 encoded data crypto key wrapped by KMS."
  type        = string
}

variable "dataset_id" {
  description = "The id of dataset the will be used."
  type        = string
}
