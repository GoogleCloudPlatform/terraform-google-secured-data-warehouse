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
  description = "The ID of the project in which the service account will be created."
  type        = string
}

variable "region" {
  description = "The region in which the subnetwork will be created."
  type        = string
}

variable "vpc_name" {
  description = "The name of the network."
  type        = string
}

variable "subnet_ip" {
  description = "The CDIR IP range of the subnetwork."
  type        = string
}
