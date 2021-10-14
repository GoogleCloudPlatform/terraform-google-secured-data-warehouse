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


module "protocol_forwarding_creation" {
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 4.0"
  constraint        = "compute.restrictProtocolForwardingCreationForTypes"
  policy_for        = "project"
  project_id        = var.project_id
  policy_type       = "list"
  allow             = ["is:INTERNAL"]
  allow_list_length = 1
}


module "serial_port_logging_policy" {
  source      = "terraform-google-modules/org-policy/google"
  version     = "~> 4.0"
  policy_for  = "project"
  project_id  = var.project_id
  constraint  = "compute.disableSerialPortLogging"
  policy_type = "boolean"
  enforce     = true
}

module "ssh_policy" {
  source      = "terraform-google-modules/org-policy/google"
  version     = "~> 4.0"
  policy_for  = "project"
  project_id  = var.project_id
  constraint  = "compute.requireOsLogin"
  policy_type = "boolean"
  enforce     = true
}

module "vpc_subnetwork_policy" {
  count             = var.trusted_subnetworks != "" ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 4.0"
  constraint        = "compute.restrictSharedVpcSubnetworks"
  policy_for        = "project"
  project_id        = var.project_id
  policy_type       = "list"
  allow             = var.trusted_subnetworks
  allow_list_length = 1
}
