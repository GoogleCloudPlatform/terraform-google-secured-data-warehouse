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

variable "projects_ids" {
  description = "Export logs from the specified list of project IDs."
  type        = list(string)
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

variable "bucket_logging_prefix" {
  description = "The prefix added to the name of the logging bucket that will store the logs."
  type        = string
}

variable "bucket_logging_location" {
  description = "A valid location for the bucket that will store the logs."
  type        = string
}

variable "kms_key_name" {
  description = "The full resource uri name for kms key that will be used to encrypt the bucket."
  type        = string
}
