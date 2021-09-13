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
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "terraform_service_account" {
  description = "The email address of the service account that will run the Terraform config."
  type        = string
}

variable "create_repository" {
  description = "When `true`, an Artifact Registry Python repository with the ID declared in `repository_id` will be created in the project declared in `project_id`. Set to `false` to reuse an existing Artifact Registry Python repository."
  type        = bool
  default     = true
}

variable "repository_id" {
  description = "ID of the Python modules repository."
  type        = string
  default     = "python-modules"
}

variable "repository_description" {
  description = "Description of the Python modules repository."
  type        = string
  default     = "Repository for Python modules for Dataflow flex templates"
}

variable "location" {
  description = "The location of Artifact Registry. Run `gcloud artifacts locations list` to list available locations."
  type        = string
  default     = "us-central1"
}

variable "read_access_members" {
  description = "List of members in the standard GCP form: user:{email}, serviceAccount:{email}, group:{email} who will have read access to the repository."
  type        = list(any)
  default     = []
}

variable "requirements_filename" {
  description = "The requirements.txt file to fetch Python modules."
  type        = string
}
