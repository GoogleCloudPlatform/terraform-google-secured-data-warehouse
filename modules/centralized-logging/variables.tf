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

variable "bucket_name" {
  description = "The prefix added to the name of the logging bucket that will store the logs."
  type        = string
}

variable "logging_location" {
  description = "A valid location for the bucket and KMS key that will be deployed."
  type        = string
  default     = "us-central-1"
}

variable "create_bucket" {
  description = "(Optional) If set to true, the module will create a bucket and a kms key; otherwise, the module will consider that the bucket already exists."
  type        = bool
  default     = true
}
