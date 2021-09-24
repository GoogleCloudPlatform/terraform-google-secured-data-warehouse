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
    "roles/datacatalog.admin",
    "roles/storage.admin",
    "roles/pubsub.admin",
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/bigquery.admin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/dns.admin",
    "roles/iam.serviceAccountCreator",
    "roles/iam.serviceAccountDeleter",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser",
    "roles/browser",
    "roles/cloudkms.admin",
    "roles/dataflow.developer",
    "roles/dlp.deidentifyTemplatesEditor",
    "roles/dlp.inspectTemplatesEditor",
    "roles/dlp.user",
    "roles/secretmanager.admin",
    "roles/cloudkms.cryptoKeyEncrypter",
    "roles/cloudscheduler.admin",
    "roles/artifactregistry.admin",
    "roles/cloudbuild.builds.editor",
    "roles/appengine.appCreator"
  ]

  projects = concat(
    values(module.data_ingestion_project)[*].project_id,
    values(module.data_governance_project)[*].project_id,
    values(module.datalake_project)[*].project_id,
    values(module.privileged_data_project)[*].project_id
  )

  project_roles = [
    for r in setproduct(local.projects, toset(local.int_proj_required_roles)) :
    {
      project_id : r[0],
      role : r[1]
    }
  ]
}

resource "google_service_account" "int_ci_service_account" {
  project      = module.data_ingestion_project[local.first_project_group].project_id
  account_id   = "ci-account"
  display_name = "ci-account"
}

resource "google_organization_iam_member" "org_admins_group" {
  for_each = toset(local.int_org_required_roles)
  org_id   = var.org_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.int_ci_service_account.email}"
}

resource "google_service_account_key" "int_test" {
  service_account_id = google_service_account.int_ci_service_account.id
}

resource "google_billing_account_iam_member" "tf_billing_user" {
  billing_account_id = var.billing_account
  role               = "roles/billing.admin"
  member             = "serviceAccount:${google_service_account.int_ci_service_account.email}"
}

resource "google_project_iam_member" "ci-account" {
  count = length(local.project_roles)

  project = local.project_roles[count.index].project_id
  role    = local.project_roles[count.index].role
  member  = "serviceAccount:${google_service_account.int_ci_service_account.email}"
}

resource "time_sleep" "wait_90_seconds" {
  depends_on = [
    google_project_iam_member.ci-account,
    google_organization_iam_member.org_admins_group
  ]

  create_duration = "90s"
}
