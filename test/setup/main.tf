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
  first_project_group  = "1"
  second_project_group = "2"
  third_project_group  = "3"
  project_groups = toset([
    local.first_project_group,
    local.second_project_group,
    local.third_project_group
  ])

  int_org_required_roles = [
    "roles/orgpolicy.policyAdmin",
    "roles/accesscontextmanager.policyAdmin",
    "roles/resourcemanager.organizationAdmin",
    "roles/vpcaccess.admin",
    "roles/compute.xpnAdmin",
    "roles/billing.user"
  ]
}

# ====================== Examples to project groups mapping ================================================
# Examples "dataflow-with-dlp" and "batch-data-ingestion" are together in one group.
# Examples "simple-example" and "regional-dlp" are together in one group.
# Examples "bigquery-confidential-data" and "de-identification-template" are together in one group.
#
# To add a new example, add it to one of the groups and try keep the number of examples that
# deploy the main module to two in that group.
# If that is not possible, try to refactor one of the examples to include your new case.
# If that is not possible, follow these step to add a new group:
#  1) Create a new project group and add it to the "project_groups" local,
#  2) In "test/setup/iam.tf" create a new set of "google_project_iam_member" resources for the new group,
#  3) In your new test fixture use the projects from the new group like "var.data_ingestion_project_id[3]",
#  4) Update "build/int.cloudbuild.yaml" to create a new sequence of build steps for the new group. The
#     initial step of the new groups must "waitFor:" the "prepare" step.
#
# See "build/int.cloudbuild.yaml" file for the build of these groups linked by "waitFor:"
# ==========================================================================================================

module "base_projects" {
  source = "./base-projects"

  for_each = local.project_groups

  org_id          = var.org_id
  folder_id       = var.folder_id
  billing_account = var.billing_account
}

resource "google_service_account" "int_ci_service_account" {
  project      = module.base_projects[local.first_project_group].data_ingestion_project_id
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
module "template_project" {
  source = "./template-project"

  org_id                   = var.org_id
  folder_id                = var.folder_id
  billing_account          = var.billing_account
  location                 = "us-east4"
  ci_service_account_email = google_service_account.int_ci_service_account.email
}
