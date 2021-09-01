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
  description = "The project IDs that will be export the logs."
  type        = list(string)
}

variable "sink_filter" {
  description = "The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs."
  type        = string
  default     = ""
}

variable "logging_project_id" {
  description = "The name of the bucket that will store the logs"
  type        = string
}

variable "bucket_logging_name" {
  description = "The location of the bucket that will store the logs."
  type        = string
}

variable "bucket_logging_location" {
  description = "The ID of the project in which the data governance resources will be created."
  type        = string
}

variable "kms_key_name" {
  description = "The kms key that will be used to encrypt the bucket."
  type        = string
}
