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

# Organizational Policies (applied at the folder level)
#
# These are the policies defined
# - Disable all public IP:  constraint/compute.vmExternalIpAccess
# - No default network: constraints/compute.skipDefaultNetworkCreation
# - No Serial Port access: constraints/compute.disableSerialPortAccess
# - No serial port logging: constraints/compute.disableSerialPortLogging
# - Require OS login: constraints/compute.requireOsLogin
# - Restrict forwarding to internal only: compute.restrictProtocolForwardingCreationForTypes"
# - Restrict Shared VPC Subnets: constraints/compute.restrictSharedVpcSubnetworks
#
# (Optional policies)
# - none

# compute.vmExternalIpAccess
module "external_ip_policy" {
  source      = "terraform-google-modules/org-policy/google"
  version     = "~> 4.0"
  constraint  = "compute.vmExternalIpAccess"
  policy_for  = "folder"
  folder_id   = local.folder_trusted
  policy_type = "list"
  enforce     = true
}

# compute.skipDefaultNetworkCreation
module "network_policy" {
  source      = "terraform-google-modules/org-policy/google"
  version     = "~> 4.0"
  policy_for  = "folder"
  folder_id   = local.folder_trusted
  constraint  = "compute.skipDefaultNetworkCreation"
  policy_type = "boolean"
  enforce     = true
}

# compute.restrictProtocolForwardingCreationForTypes
module "protocol_forwarding_creation" {
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 4.0"
  constraint        = "compute.restrictProtocolForwardingCreationForTypes"
  policy_for        = "folder"
  folder_id         = local.folder_trusted
  policy_type       = "list"
  allow             = ["is:INTERNAL"]
  allow_list_length = 1
}

# compute.disableSerialPortAccess
module "serial_port_access_policy" {
  source      = "terraform-google-modules/org-policy/google"
  version     = "~> 4.0"
  policy_for  = "folder"
  folder_id   = local.folder_trusted
  constraint  = "compute.disableSerialPortAccess"
  policy_type = "boolean"
  enforce     = true
}

# compute.disableSerialPortLogging
module "serial_port_logging_policy" {
  source      = "terraform-google-modules/org-policy/google"
  version     = "~> 4.0"
  policy_for  = "folder"
  folder_id   = local.folder_trusted
  constraint  = "compute.disableSerialPortLogging"
  policy_type = "boolean"
  enforce     = true
}

# compute.requireOsLogin
module "ssh_policy" {
  source      = "terraform-google-modules/org-policy/google"
  version     = "~> 4.0"
  policy_for  = "folder"
  folder_id   = local.folder_trusted
  constraint  = "compute.requireOsLogin"
  policy_type = "boolean"
  enforce     = true
}

# compute.restrictSharedVpcSubnetworks
module "vpc_subnet_policy" {
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 4.0"
  constraint        = "compute.restrictSharedVpcSubnetworks"
  policy_for        = "folder"
  folder_id         = local.folder_trusted
  policy_type       = "list"
  allow             = ["under:projects/${split("/", var.trusted_private_subnet)[1]}"] 
  allow_list_length = 1
}
