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
  description = "(Optional) Default label used by Data Warehouse resources."
  type        = map(string)
  default = {
    environment = "default"
  }
}

variable "projects_ids" {
  description = "Export logs from the specified list of project IDs."
  type        = map(string)
}

variable "sink_filter" {
  description = "The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs."
  type        = string
  default     = ""
}

variable "logging_project_id" {
  description = "The ID of the project in which the bucket for the logs will be created."
  type        = string
}

variable "kms_project_id" {
  description = "The ID of the project in which the Cloud KMS keys will be created."
  type        = string
}

variable "bucket_name" {
  description = "The name of the logging bucket that will store the logs."
  type        = string
}

variable "parent_folder" {
  description = "The folder id that will be configured so all its projects will add data logs for every resource."
  type        = string
}

variable "logging_location" {
  description = "A valid location for the bucket and KMS key that will be deployed."
  type        = string
  default     = "us-east4"
}

variable "create_bucket" {
  description = "(Optional) If set to true, the module will create a bucket and a kms key; otherwise, the module will consider that the bucket already exists."
  type        = bool
  default     = true
}

variable "delete_contents_on_destroy" {
  description = "(Optional) If set to true, disable the prevent destroy protection in the KMS keys."
  type        = bool
  default     = false
}

variable "key_rotation_period_seconds" {
  description = "Rotation period for keys. The default value is 30 days."
  type        = string
  default     = "2592000s"
}

variable "kms_key_protection_level" {
  description = "The protection level to use when creating a key. Possible values: [\"SOFTWARE\", \"HSM\"]"
  type        = string
  default     = "HSM"
}

variable "data_access_logs_enabled" {
  description = "Enable Data Access logs of types DATA_READ, DATA_WRITE for all GCP services in the projects under the provided `parent_folder`. Enabling Data Access logs might result in your organization being charged for the additional logs usage. See https://cloud.google.com/logging/docs/audit#data-access The ADMIN_READ logs are enabled by default."
  type        = bool
  default     = false
}
