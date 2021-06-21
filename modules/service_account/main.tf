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
  organization_roles = var.org_id != "" ? toset(var.organization_roles) : toset([])
  project_roles      = toset(var.project_roles)
}

// service account
resource "google_service_account" "service_account" {
  project      = var.project_id
  account_id   = var.account_id
  display_name = var.display_name
}

// project roles
resource "google_project_iam_member" "project_binding" {
  for_each = local.project_roles
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.service_account.email}"
}

// organization roles
resource "google_organization_iam_member" "organization_binding" {
  for_each = local.organization_roles
  org_id   = var.org_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.service_account.email}"
}
