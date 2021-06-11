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

locals {
  int_org_required_roles = [
    "roles/orgpolicy.policyAdmin",
    "roles/accesscontextmanager.policyAdmin",
    "roles/resourcemanager.organizationAdmin",
    "roles/vpcaccess.admin",
    "roles/compute.xpnAdmin",
    "roles/billing.user"
  ]

  int_proj_required_roles = [
    "roles/storage.admin",
    "roles/pubsub.admin",
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/bigquery.admin",
    "roles/dns.admin",
    "roles/iam.serviceAccountCreator",
    "roles/iam.serviceAccountDeleter",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser",
    "roles/owner"
  ]
}

resource "google_organization_iam_member" "org_admins_group" {
  for_each = toset(local.int_org_required_roles)
  org_id   = var.org_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.int_test.email}"
}

resource "google_billing_account_iam_member" "tf_billing_user" {
  billing_account_id = var.billing_account
  role               = "roles/billing.admin"
  member             = "serviceAccount:${google_service_account.int_test.email}"
}

resource "google_service_account" "int_test" {
  project      = module.project.project_id
  account_id   = "ci-account"
  display_name = "ci-account"
}

resource "google_project_iam_member" "int_test" {
  for_each = toset(local.int_proj_required_roles)

  project = module.project.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.int_test.email}"
}

resource "google_service_account_key" "int_test" {
  service_account_id = google_service_account.int_test.id
}

resource "null_resource" "wait_iam_propagation" {
  # Adding a pause to wait for IAM propagation
  provisioner "local-exec" {
    command = "echo sleep 90s for IAM propagation; sleep 90"
  }
  depends_on = [google_project_iam_member.int_test, google_organization_iam_member.org_admins_group]
}
