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
  description = "Project where the dataset and table are created"
  type        = string
}

variable "dataset_id" {
  description = "The dataset ID to deploy to data-warehouse"
  type        = string
  default     = "dtwh_dataset"
}

variable "table_id" {
  description = "The table ID to deploy to datawarehouse."
  type        = string
  default     = "sample_data"
}

variable "taxonomy_name" {
  description = "The taxonomy display name."
  type        = string
  default     = "secure_taxonomy_bq"
}

variable "location" {
  description = "Default region to create resources where applicable."
  type        = string
  default     = "us-east1"
}

variable "terraform_service_account" {
  description = "Service account email of the account to impersonate to run Terraform"
  type        = string
}
