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

variable "trusted_locations" {
  description = "This is a list of trusted regions where location-based GCP resources can be created. ie us-locations eu-locations."
  type        = list(string)
  default     = ["us-locations", "eu-locations"]
}

variable "org_id" {
  description = "GCP Organization ID."
  type        = string
}

variable "region" {
  description = "The region in which the resources will be deployed."
  type        = string
  default     = "us-central1"
}

variable "location" {
  description = "The location for the KMS Customer Managed Encryption Keys, Bucket, and Bigquery dataset. This location can be a multiregion, if it is empty the region value will be used."
  type        = string
  default     = ""
}

variable "terraform_service_account" {
  description = "The email address of the service account that will run the Terraform code."
  type        = string
}

variable "project_id" {
  description = "The ID of the project in which the service account will be created."
  type        = string
}

variable "data_governance_project_id" {
  description = "The ID of the project in which the data governance resources will be created."
  type        = string
}

variable "vpc_name" {
  description = "The name of the network."
  type        = string
}

variable "subnet_ip" {
  description = "The CDIR IP range of the subnetwork."
  type        = string
}

variable "access_context_manager_policy_id" {
  description = "The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format=\"value(name)\"`."
  type        = number
}

variable "perimeter_additional_members" {
  description = "The list additional members to be added on perimeter access. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required."
  type        = list(string)
  default     = []
}

variable "bucket_name" {
  description = "The name of for the bucket being provisioned."
  type        = string
}

variable "bucket_class" {
  description = "The storage class for the bucket being provisioned."
  type        = string
  default     = "STANDARD"
}

variable "bucket_lifecycle_rules" {
  description = "List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches_storage_class should be a comma delimited string."
  type = set(object({
    action    = any
    condition = any
  }))
  default = [{
    action = {
      type = "Delete"
    }
    condition = {
      age                   = 30
      with_state            = "ANY"
      matches_storage_class = ["STANDARD"]
    }
  }]
}

variable "dataset_id" {
  description = "Unique ID for the dataset being provisioned."
  type        = string
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

variable "dataset_default_table_expiration_ms" {
  description = "TTL of tables using the dataset in MS. The default value is almost 12 months."
  type        = number
  default     = 31536000000
}

variable "cmek_keyring_name" {
  description = "The Keyring name for the KMS Customer Managed Encryption Keys being provisioned."
  type        = string
}
