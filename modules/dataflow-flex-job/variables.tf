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
    environment = ""
  }
}

variable "project_id" {
  description = "The project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
}

variable "name" {
  description = "The name of the dataflow flex job."
  type        = string
}

variable "container_spec_gcs_path" {
  description = "The GCS path to the Dataflow job flex template."
  type        = string
}

variable "temp_location" {
  description = "GCS path for saving temporary workflow jobs."
  type        = string
}

variable "staging_location" {
  description = "GCS path for staging code packages needed by workers."
  type        = string
}

variable "job_language" {
  description = "Language of the flex template code. Options are 'JAVA' or 'PYTHON'."
  type        = string
  default     = "JAVA"

  validation {
    condition     = var.job_language == "JAVA" || var.job_language == "PYTHON"
    error_message = "Invalid job language. Options are 'JAVA' or 'PYTHON'."
  }
}

variable "enable_streaming_engine" {
  description = "Enable/disable the use of Streaming Engine for the job. Note that Streaming Engine is enabled by default for pipelines developed against the Beam SDK for Python v2.21.0 or later when using Python 3."
  type        = bool
  default     = true
}

variable "parameters" {
  description = "Key/Value pairs to be passed to the Dataflow job (as used in the template)."
  type        = map(any)
  default     = {}
}

variable "max_workers" {
  description = "The number of workers permitted to work on the job. More workers may improve processing speed at additional cost."
  type        = number
  default     = 1
}

variable "on_delete" {
  description = "One of drain or cancel. Specifies behavior of deletion during terraform destroy. The default is cancel. See https://cloud.google.com/dataflow/docs/guides/stopping-a-pipeline ."
  type        = string
  default     = "cancel"
}

variable "region" {
  description = "The region in which the created job should run."
  type        = string
}

variable "service_account_email" {
  description = "The Service Account email that will be used to identify the VMs in which the jobs are running. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#worker_service_account ."
  type        = string
}

variable "subnetwork_self_link" {
  description = "The subnetwork self link to which VMs will be assigned."
  type        = string
}

variable "use_public_ips" {
  description = "If VM instances should used public IPs."
  type        = string
  default     = false
}

variable "network_tags" {
  description = "Network TAGs to be added to the VM instances. Python flex template jobs are only able to set network tags for the launcher VM. For the harness VM it is necessary to configure your firewall rule to use the network tag 'dataflow'."
  type        = list(string)
  default     = []
}

variable "kms_key_name" {
  description = "The name for the Cloud KMS key for the job. Key format is: `projects/PROJECT_ID/locations/LOCATION/keyRings/KEY_RING/cryptoKeys/KEY`."
  type        = string
}

variable "additional_experiments" {
  description = "Comma separated list of additional experiments to be used by the job."
  type        = string
  default     = ""
}
