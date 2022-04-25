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
  folder_admin_roles = [
    "roles/resourcemanager.projectCreator",
    "roles/compute.networkAdmin",
    "roles/cloudkms.cryptoOperator",
    "roles/logging.admin",
    "roles/resourcemanager.projectDeleter",
    "roles/resourcemanager.projectIamAdmin",
    "roles/serviceusage.serviceUsageAdmin",
  ]
}

resource "google_organization_iam_member" "standalone-org-roles" {
  org_id = var.org_id
  role   = "roles/resourcemanager.folderAdmin"
  member = "serviceAccount:${var.terraform_service_account}"
}

resource "time_sleep" "wait_120_folder" {
  create_duration = "120s"

  depends_on = [
    google_organization_iam_member.standalone-org-roles
  ]
}

resource "random_id" "name" {
  byte_length = 6
}

resource "google_folder" "folders" {
  display_name = "fldr-standalone-${random_id.name.hex}"
  parent       = "folders/${var.folder_id}"

  depends_on = [
    time_sleep.wait_120_folder
  ]
}

resource "google_folder_iam_member" "terraform_sa" {
  for_each = toset(local.folder_admin_roles)
  folder   = google_folder.folders.name
  role     = each.value
  member   = "serviceAccount:${var.terraform_service_account}"
}

resource "time_sleep" "wait_120" {
  create_duration = "120s"

  depends_on = [
    google_folder_iam_member.terraform_sa
  ]
}

module "example" {
  source                           = "../../../examples/standalone"
  org_id                           = var.org_id
  folder_id                        = google_folder.folders.name
  billing_account                  = var.billing_account
  access_context_manager_policy_id = var.access_context_manager_policy_id
  terraform_service_account        = var.terraform_service_account
  perimeter_additional_members     = []
  delete_contents_on_destroy       = true
  data_engineer_group              = var.group_email[2]
  data_analyst_group               = var.group_email[2]
  security_analyst_group           = var.group_email[2]
  network_administrator_group      = var.group_email[2]
  security_administrator_group     = var.group_email[2]

  depends_on = [
    time_sleep.wait_120
  ]
}

