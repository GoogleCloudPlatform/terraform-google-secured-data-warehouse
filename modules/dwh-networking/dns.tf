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


/******************************************
  Default DNS Policy
 *****************************************/

resource "google_dns_policy" "default_policy" {
  project                   = var.project_id
  name                      = "default-policy"
  enable_inbound_forwarding = "true"
  enable_logging            = "true"
  networks {
    network_url = module.network.network_self_link
  }
}

/******************************************
  Restricted Google APIs DNS Zone & records.
 *****************************************/

module "restricted_googleapis" {
  source      = "terraform-google-modules/cloud-dns/google"
  version     = "~> 5.0"
  project_id  = var.project_id
  type        = "private"
  name        = "dz-e-shared-restricted-apis"
  domain      = "googleapis.com."
  description = "Private DNS zone to configure restricted.googleapis.com"

  private_visibility_config_networks = [
    module.network.network_self_link
  ]

  recordsets = [
    {
      name    = "*"
      type    = "CNAME"
      ttl     = 300
      records = ["restricted.googleapis.com."]
    },
    {
      name    = "securitycenter"
      type    = "CNAME"
      ttl     = 300
      records = ["private.googleapis.com."]
    },
    {
      name    = "restricted"
      type    = "A"
      ttl     = 300
      records = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]
    },
    {
      name    = "private"
      type    = "A"
      ttl     = 300
      records = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
    },
  ]
}

module "restricted_gcr" {
  source      = "terraform-google-modules/cloud-dns/google"
  version     = "~> 5.0"
  project_id  = var.project_id
  type        = "private"
  name        = "dz-e-shared-restricted-gcr"
  domain      = "gcr.io."
  description = "Private DNS zone to configure gcr.io"

  private_visibility_config_networks = [
    module.network.network_self_link
  ]

  recordsets = [
    {
      name    = "*"
      type    = "CNAME"
      ttl     = 300
      records = ["gcr.io."]
    },
    {
      name    = ""
      type    = "A"
      ttl     = 300
      records = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]
    },
  ]
}

/**************************************************
  Restricted Artifact Registry DNS Zone & records.
 **************************************************/

module "restricted_pkg_dev" {
  source      = "terraform-google-modules/cloud-dns/google"
  version     = "~> 5.0"
  project_id  = var.project_id
  type        = "private"
  name        = "dz-e-shared-restricted-pkg-dev"
  domain      = "pkg.dev."
  description = "Private DNS zone to configure pkg.dev"

  private_visibility_config_networks = [
    module.network.network_self_link
  ]

  recordsets = [
    {
      name    = "*"
      type    = "CNAME"
      ttl     = 300
      records = ["pkg.dev."]
    },
    {
      name    = ""
      type    = "A"
      ttl     = 300
      records = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]
    },
  ]
}
