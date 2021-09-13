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
  description = "When `true`, an Artifact Registry Docker repository with the ID declared in `repository_id` will be created in the project declared in `project_id`. Set to `false` to reuse an existing Artifact Registry Docker repository."
  type        = bool
  default     = true
}

variable "repository_id" {
  description = "ID of the flex template repository."
  type        = string
  default     = "flex-templates"
}

variable "repository_description" {
  description = "Description of the flex template repository."
  type        = string
  default     = "Repository for Dataflow flex templates"
}

variable "location" {
  description = "The location of Artifact registry. Run `gcloud artifacts locations list` to list available locations."
  type        = string
  default     = "us-central1"
}

variable "image_name" {
  description = "Name of the flex image."
  type        = string
}

variable "image_tag" {
  description = "The TAG of the image."
  type        = string
  default     = "v1.0.0"
}

variable "template_files" {
  description = "The files needed to create the template. See https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates#python."
  type = object(
    {
      metadata_file     = string,
      requirements_file = string,
      code_file         = string
    }
  )
}

variable "python_modules_private_repo" {
  description = "The private Python modules repository. If using artifact registry should be in the format https://LOCATION-python.pkg.dev/PROJECT_ID/REPO_NAME/simple/."
  type        = string
}

variable "read_access_members" {
  description = "List of members in the standard GCP form: user:{email}, serviceAccount:{email}, group:{email} who will have read access to the repository."
  type        = list(any)
  default     = []
}

variable "kms_key_name" {
  description = "ID of a Cloud KMS key that will be used for encryption."
  type        = string
}
