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
  description = "The region in which subnetwork will be created and Pub/Sub message will be stored."
  type        = string
  default     = "us-east4"
}

variable "terraform_service_account" {
  description = "The email address of the service account that will run the Terraform code."
  type        = string
}

variable "data_ingestion_project_id" {
  description = "The ID of the project in which the data ingestion resources will be created."
  type        = string
}

variable "non_confidential_data_project_id" {
  description = "The ID of the project in which the Bigquery will be created."
  type        = string
}

variable "data_governance_project_id" {
  description = "The ID of the project in which the KMS and DLP are created."
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

variable "bucket_class" {
  description = "Bucket storage class."
  type        = string
  default     = "STANDARD"
}

variable "delete_contents_on_destroy" {
  description = "(Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present."
  type        = bool
  default     = false
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

variable "dataset_location" {
  description = "The regional location for the dataset only US and EU are allowed in module."
  type        = string
  default     = "US"
}

variable "dataset_default_table_expiration_ms" {
  description = "TTL of tables using the dataset in MS. The default value is null."
  type        = number
  default     = null
}

variable "bigquery_encryption_key" {
  description = "Self-link of the encryption key to be used by Bigquery."
  type        = string
}

variable "ingestion_encryption_key" {
  description = "Self-link of the encryption key to be used by Pub/Sub and Storage."
  type        = string
}
