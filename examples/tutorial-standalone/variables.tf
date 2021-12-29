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
  description = "The numeric organization id."
}

variable "folder_id" {
  description = "The folder to deploy in."
}

variable "billing_account" {
  description = "The billing account id associated with the projects, e.g. XXXXXX-YYYYYY-ZZZZZZ."
}

variable "access_context_manager_policy_id" {
  description = "The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format=\"value(name)\"`."
  type        = string
  default     = ""
}

variable "terraform_service_account" {
  description = "The email address of the service account that will run the Terraform code."
  type        = string
}

variable "perimeter_additional_members" {
  description = "The list of all members to be added on perimeter access, except the service accounts created by this module. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required."
  type        = list(string)
}

variable "delete_contents_on_destroy" {
  description = "(Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present."
  type        = bool
  default     = false
}

variable "kms_key_protection_level" {
  description = "The protection level to use when creating a key. Possible values: [\"SOFTWARE\", \"HSM\"]"
  type        = string
  default     = "HSM"
}

variable "security_administrator_group" {
  description = "Google Cloud IAM group that administers security configurations in the organization(org policies, KMS, VPC service perimeter)."
  type        = string
}

variable "network_administrator_group" {
  description = "Google Cloud IAM group that reviews network configuration. Typically, this includes members of the networking team."
  type        = string
}

variable "security_analyst_group" {
  description = "Google Cloud IAM group that monitors and responds to security incidents."
  type        = string
}

variable "data_analyst_group" {
  description = "Google Cloud IAM group that analyzes the data in the warehouse."
  type        = string
}

variable "data_engineer_group" {
  description = "Google Cloud IAM group that sets up and maintains the data pipeline and warehouse."
  type        = string
}
