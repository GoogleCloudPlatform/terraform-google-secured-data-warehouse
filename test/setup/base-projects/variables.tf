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

variable "labels" {
  description = "(Optional) Labels attached to Data Warehouse resources."
  type        = map(string)
  default     = {}
}

variable "org_id" {
  description = "The numeric organization id"
  type        = string
}

variable "folder_id" {
  description = "The folder to deploy in"
  type        = string
}

variable "billing_account" {
  description = "The billing account id associated with the project, e.g. XXXXXX-YYYYYY-ZZZZZZ"
  type        = string
}

variable "region" {
  description = "The region in which the subnetwork and the App Engine application will be created."
  type        = string
}

variable "data_ingestion_project_name" {
  description = "Custom project name for the data ingestion project."
  type        = string
  default     = ""
}

variable "data_governance_project_name" {
  description = "Custom project name for the data governance project."
  type        = string
  default     = ""
}

variable "non_confidential_data_project_name" {
  description = "Custom project name for the non confidential data project."
  type        = string
  default     = ""
}

variable "confidential_data_project_name" {
  description = "Custom project name for the confidential data project."
  type        = string
  default     = ""
}
