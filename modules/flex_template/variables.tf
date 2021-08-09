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

variable "create_flex_repository" {
  type        = bool
  description = "If the flex template repository should be created."
  default     = true
}

variable "location" {
  description = "The location of Artifact registry. Run `gcloud artifacts locations list` to list available locations."
  type        = string
  default     = "us-central1"
}

variable "repository_id" {
  type        = string
  description = "ID of the flex template repository."
  default     = "flex-templates"
}

variable "repository_description" {
  type        = string
  description = "Description of the flex template repository."
  default     = "Repository for Dataflow flex templates"
}

variable "image_name" {
  type        = string
  description = "Name of the flex image."
}

variable "image_tag" {
  type        = string
  description = "The TAG of the image."
  default     = "v1.0.0"
}

variable "template_files" {
  type = object(
    {
      metadata_file     = string,
      requirements_file = string,
      code_file         = string
    }
  )
  description = "The files needed to create the template. See https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates#python ."
}

variable "python_modules_private_repo" {
  type        = string
  description = "The private Python modules repository. If using artifact registry should be in the format https://LOCATION-python.pkg.dev/PROJECT_ID/REPO_NAME/simple/"
}

variable "read_access_members" {
  type        = list
  description = "List of members in the standard GCP form: user:{email}, serviceAccount:{email}, group:{email} who will have read access to the repository."
  default     = []
}

variable "module_depends_on" {
  description = "List of modules or resources this module depends on."
  type        = list
  default     = []
}

variable "kms_key_name" {
  description = "ID of a Cloud KMS key that will be used for encryption."
  type        = string
}
