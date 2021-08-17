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

variable "terraform_service_account" {
  description = "Service account email of the account to impersonate to run Terraform."
  type        = string
}

variable "org_id" {
  description = "GCP Organization ID."
  type        = string
}

variable "project_id" {
  description = "The ID of the project in which the service account will be created."
  type        = string
}

variable "access_context_manager_policy_id" {
  type        = number
  description = "The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format=\"value(name)\"`."
}

variable "ip_configuration" {
  type        = string
  description = "The configuration for VM IPs. Options are 'WORKER_IP_PUBLIC' or 'WORKER_IP_PRIVATE'."
  default     = "WORKER_IP_PRIVATE"
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

variable "dlp_location" {
  description = "The location of DLP resources. See https://cloud.google.com/dlp/docs/locations. The 'global' KMS location is valid."
  type        = string
  default     = "us"
}

variable "subnet_ip" {
  type        = string
  description = "The CDIR IP range of the subnetwork."
  default     = "10.0.32.0/21"
}

variable "perimeter_additional_members" {
  description = "The list additional members to be added on perimeter access. Prefix of group: user: or serviceAccount: is required."
  type        = list(string)
  default     = []
}

variable "bucket_name" {
  description = "The main part of the name of the data ingestion bucket to be created."
  type        = string
  default     = "bkt-data-ingestion"
}

variable "dataset_id" {
  description = "Unique ID for the dataset being provisioned."
  type        = string
  default     = "dts_data_ingestion"
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

variable "cmek_location" {
  description = "The location for the KMS Customer Managed Encryption Keys."
  type        = string
  default     = "us"
}

variable "cmek_keyring_name" {
  description = "The Keyring name for the KMS Customer Managed Encryption Keys."
  type        = string
  default     = "cmek_keyring"
}
