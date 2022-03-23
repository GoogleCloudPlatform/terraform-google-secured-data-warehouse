/**
 * Copyright 2022 Google LLC
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

variable "data_ingestion_project_id" {
  description = "Data ingestion project ID."
  type        = string
}

variable "non_confidential_data_project_id" {
  description = "Non-confidential data project ID."
  type        = string
}

variable "data_governance_project_id" {
  description = "Data governance project ID."
  type        = string
}

variable "confidential_data_project_id" {
  description = "Confidential data project ID."
  type        = string
}

variable "service_account_email" {
  description = "Terraform service account."
  type        = string
}
