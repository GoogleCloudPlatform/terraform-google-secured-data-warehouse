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
  description = "The project id for the secured data warehouse."
  type        = string
}

variable "region" {
  description = "The region in which the subnetwork resides."
  type        = string
}

variable "trusted_subnetworks" {
  description = "Subnetwork name that eligible resources can use."
  type        = list(string)
  default     = [""]
}

variable "trusted_locations" {
  description = "This is a list of trusted regions where location-based GCP resources can be created. ie us-locations eu-locations."
  type        = list(string)
  default     = ["us-locations", "eu-locations"]
}
