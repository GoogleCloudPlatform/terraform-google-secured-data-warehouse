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

locals {
  ingestion_proj_required_roles = [
    "roles/storage.admin",
    "roles/pubsub.admin",
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/dns.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/dataflow.developer",
    "roles/iam.serviceAccountAdmin",
    "roles/cloudscheduler.admin",
    "roles/appengine.appCreator",
    "roles/iam.serviceAccountTokenCreator"
  ]

  confidential_proj_required_roles = [
    "roles/storage.admin",
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/bigquery.admin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/dns.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/dataflow.developer",
    "roles/iam.serviceAccountTokenCreator"
  ]

  non_confidential_proj_required_roles = [
    "roles/storage.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/bigquery.admin",
    "roles/iam.serviceAccountTokenCreator"
  ]

  governance_proj_required_roles = [
    "roles/datacatalog.admin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/cloudkms.admin",
    "roles/storage.admin",
    "roles/dlp.deidentifyTemplatesEditor",
    "roles/dlp.inspectTemplatesEditor",
    "roles/dlp.user",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/iam.serviceAccountTokenCreator",
    "roles/secretmanager.admin"
  ]
}

resource "google_project_iam_member" "ci-account-data-ingestion" {
  for_each = toset(local.ingestion_proj_required_roles)

  project = var.data_ingestion_project_id
  role    = each.value
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "ci-account-non-confidential" {
  for_each = toset(local.non_confidential_proj_required_roles)

  project = var.non_confidential_data_project_id
  role    = each.value
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "ci-account-governance" {
  for_each = toset(local.governance_proj_required_roles)

  project = var.data_governance_project_id
  role    = each.value
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "ci-account-confidential" {
  for_each = toset(local.confidential_proj_required_roles)

  project = var.confidential_data_project_id
  role    = each.value
  member  = "serviceAccount:${var.service_account_email}"
}
