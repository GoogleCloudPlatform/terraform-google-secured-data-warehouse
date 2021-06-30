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

variable "region" {
  type        = string
  description = "The region in which the subnetwork will be created."
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "The zone in which the created job should run."
  default     = "us-central1-a"
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

variable "ip_configuration" {
  type        = string
  description = "The configuration for VM IPs. Options are 'WORKER_IP_PUBLIC' or 'WORKER_IP_PRIVATE'."
  default     = "WORKER_IP_PRIVATE"
}

variable "terraform_service_account" {
  description = "Service account email of the account to impersonate to run Terraform."
  type        = string
}

variable "project_id" {
  description = "The ID of the project in which the service account will be created."
  type        = string
}

variable "bucket_name" {
  description = "The main part of the name of the bucket to be created."
  type        = string
}

variable "bucket_location" {
  description = "Bucket location."
  type        = string
  default     = "US"
}

variable "bucket_force_destroy" {
  type        = bool
  description = "When deleting a bucket, this boolean option will delete all contained objects. If you try to delete a bucket that contains objects, Terraform will fail that run."
  default     = false
}

variable "bucket_lifecycle_rules" {
  type = set(object({
    action    = map(string)
    condition = map(string)
  }))
  description = "List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches_storage_class should be a comma delimited string."
  default = [{
    action = {
      type = "Delete"
    }
    condition = {
      age        = 30
      with_state = "ANY"
    }
  }]
}

variable "dataset_id" {
  description = "Unique ID for the dataset being provisioned."
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

variable "dlp_location" {
  description = "The location of DLP resources. See https://cloud.google.com/dlp/docs/locations. The 'global' KMS location is valid."
  type        = string
  default     = "global"
}

variable "change_sample_file_encoding" {
  description = "Flag to decide if the encoding of the the sample file should be converted to UTF-8."
  type        = string
  default     = "true"
}

variable "sample_file_original_encoding" {
  description = "(Optional) The original encoding of the sample file."
  type        = string
  default     = "ISO-8859-1"
}
