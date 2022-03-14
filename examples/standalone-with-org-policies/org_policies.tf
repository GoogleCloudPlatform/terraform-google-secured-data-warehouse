/**
 * Copyright 2022 Google LLC
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

module "org_domain_restricted_sharing" {
  for_each = local.projects_ids

  source           = "terraform-google-modules/org-policy/google//modules/domain_restricted_sharing"
  version          = "~> 3.0"
  project_id       = each.value
  policy_for       = "project"
  domains_to_allow = var.domains_to_allow

  depends_on = [
    module.secured_data_warehouse
  ]
}

module "org_enforce_bucket_level_access" {
  for_each = local.projects_ids

  source      = "terraform-google-modules/org-policy/google"
  version     = "~> 3.0"
  project_id  = each.value
  policy_for  = "project"
  policy_type = "boolean"
  enforce     = "true"
  constraint  = "constraints/storage.uniformBucketLevelAccess"

  depends_on = [
    module.secured_data_warehouse
  ]
}

module "org_enforce_detailed_audit_logging_mode" {
  for_each = local.projects_ids

  source      = "terraform-google-modules/org-policy/google"
  version     = "~> 3.0"
  project_id  = each.value
  policy_for  = "project"
  policy_type = "boolean"
  enforce     = "true"
  constraint  = "constraints/gcp.detailedAuditLoggingMode"

  depends_on = [
    module.secured_data_warehouse
  ]
}

module "org_enforce_public_access_prevention" {
  for_each = local.projects_ids

  source      = "terraform-google-modules/org-policy/google"
  version     = "~> 3.0"
  project_id  = each.value
  policy_for  = "project"
  policy_type = "boolean"
  enforce     = "true"
  constraint  = "constraints/storage.publicAccessPrevention"

  depends_on = [
    module.secured_data_warehouse
  ]
}
