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
  description = "The GCP Organization ID."
  type        = string
  default     = ""
}

variable "project_id" {
  description = "The ID of the project in which the service account will be created."
  type        = string
}

variable "account_id" {
  description = "The ID of the service account to be created."
  type        = string
}

variable "display_name" {
  description = "The display name of the service account to be created."
  type        = string
}

variable "project_roles" {
  type        = list(string)
  description = "The roles to be granted to the service account in the project."
  default     = []
}

variable "organization_roles" {
  type        = list(string)
  description = "The roles to be granted to the service account in the organization."
  default     = []
}
