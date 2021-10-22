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
    "roles/cloudkms.cryptoKeyEncrypter",
    "roles/cloudscheduler.admin",
    "roles/appengine.appCreator"
  ]
}

resource "google_project_iam_member" "ci-account-ingestion" {
  for_each = toset(local.int_proj_required_roles)

  project = var.data_ingestion_project_id
  role    = each.value
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "ci-account-datalake" {
  for_each = toset(local.int_proj_required_roles)

  project = var.datalake_project_id
  role    = each.value
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "ci-account-governance" {
  for_each = toset(local.int_proj_required_roles)

  project = var.data_governance_project_id
  role    = each.value
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "ci-account-confidential" {
  for_each = toset(local.int_proj_required_roles)

  project = var.confidential_data_project_id
  role    = each.value
  member  = "serviceAccount:${var.service_account_email}"
}
