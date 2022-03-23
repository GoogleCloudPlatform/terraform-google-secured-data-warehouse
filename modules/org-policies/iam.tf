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

# Organizational Policies (applied at the project level)
#
# These are the minimum policies
# - No SA Key creation: constraints/iam.disableServiceAccountKeyCreation
#
# (Optional policies)
# - No outside domains: constraints/iam.allowedPolicyMemberDomains



module "service_account_key_policy" {
  source      = "terraform-google-modules/org-policy/google"
  version     = "~> 5.0"
  policy_for  = "project"
  project_id  = var.project_id
  constraint  = "iam.disableServiceAccountCreation"
  policy_type = "boolean"
  enforce     = true
}
