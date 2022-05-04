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
  description = "(Deprecated) The folder id that would be configured so that all its projects would add data logs for every resource. Data logs are now configured at the projects from the `projects_ids` variable."
  type        = string
  default     = ""
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
  description = "Enable Data Access logs of types DATA_READ, DATA_WRITE for all GCP services in the projects specified in the provided `projects_ids` map. Enabling Data Access logs might result in your organization being charged for the additional logs usage. See https://cloud.google.com/logging/docs/audit#data-access The ADMIN_READ logs are enabled by default."
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  type = set(object({
    # Object with keys:
    # - type - The type of the action of this Lifecycle Rule. Supported values: Delete and SetStorageClass.
    # - storage_class - (Required if action type is SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule.
    action = map(string)

    # Object with keys:
    # - age - (Optional) Minimum age of an object in days to satisfy this condition.
    # - created_before - (Optional) Creation date of an object in RFC 3339 (e.g. 2017-06-13) to satisfy this condition.
    # - with_state - (Optional) Match to live and/or archived objects. Supported values include: "LIVE", "ARCHIVED", "ANY".
    # - matches_storage_class - (Optional) Comma delimited string for storage class of objects to satisfy this condition. Supported values include: MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, STANDARD, DURABLE_REDUCED_AVAILABILITY.
    # - num_newer_versions - (Optional) Relevant only for versioned objects. The number of newer versions of an object to satisfy this condition.
    # - days_since_custom_time - (Optional) The number of days from the Custom-Time metadata attribute after which this condition becomes true.
    condition = map(string)
  }))
  description = "List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches_storage_class should be a comma delimited string."
  default = [

    {
      action = {
        type          = "SetStorageClass"
        storage_class = "COLDLINE"
      }
      condition = {
        age        = 90
        with_state = "ANY"
      }
    },
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "ARCHIVE"
      }
      condition = {
        age        = 365
        with_state = "ANY"
      }
    },
    {
      action = {
        type = "Delete"
      }
      condition = {
        age        = 400
        with_state = "ANY"
      }
    },
  ]
}

variable "retention_policy" {
  description = "Configuration of the bucket's data retention policy for how long objects in the bucket should be retained (in days)."
  type = object({
    is_locked             = bool
    retention_period_days = number
  })
  default = {
    is_locked             = true
    retention_period_days = 30
  }
}
