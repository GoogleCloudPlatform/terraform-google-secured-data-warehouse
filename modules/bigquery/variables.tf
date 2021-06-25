/**
 * Copyright 2018 Google LLC
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

variable "enable" {
  description = "Actually enable the APIs listed."
  type        = bool
  default     = false
}

variable "delete_contents_on_destroy" {
  description = "(Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present."
  type        = bool
  default     = null
}

variable "label_dataset" {
  type        = string
  description = "Label used in dataset."
}

variable "names" {
  type        = list(string)
  description = "Names of the service accounts to create."
  default     = []
}

variable "project_roles" {
  type        = list(string)
  description = "Common roles to apply to all service accounts in the project."
  default     = []
}

variable "project_id" {
  description = "Project where the dataset and table are created."
  type        = string
}

variable "dataset_id" {
  description = "The dataset ID to deploy to datawarehouse."
  type        = string
}

variable "table_id" {
  description = "The table ID to deploy to datawarehouse."
  type        = string
}

variable "parent_folder" {
  description = "Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist."
  type        = string
  default     = ""
}

variable "location" {
  description = "Default region to create resources where applicable."
  type        = string
}
