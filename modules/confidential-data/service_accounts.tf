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
  confidential_project_roles = [
    "roles/pubsub.subscriber",
    "roles/bigquery.admin",
    "roles/cloudkms.admin",
    "roles/cloudkms.cryptoKeyDecrypter",
    "roles/dlp.admin",
    "roles/dlp.deidentifyTemplatesEditor",
    "roles/dlp.user",
    "roles/storage.admin",
    "roles/dataflow.serviceAgent",
    "roles/dataflow.worker",
    "roles/compute.viewer",
    "roles/serviceusage.serviceUsageConsumer"
  ]

  governance_project_roles = [
    "roles/serviceusage.serviceUsageConsumer",
    "roles/dlp.admin",
    "roles/dlp.deidentifyTemplatesEditor",
    "roles/dlp.user",
    "roles/cloudkms.admin",
    "roles/cloudkms.cryptoKeyDecrypter"
  ]

  non_conf_project_roles = [
    "roles/bigquery.admin",
    "roles/serviceusage.serviceUsageConsumer"
  ]
}

module "dataflow_controller_service_account" {
  source       = "terraform-google-modules/service-accounts/google"
  version      = "~> 3.0"
  project_id   = var.confidential_data_project_id
  names        = ["sa-dataflow-controller-reid"]
  display_name = "Cloud Dataflow controller service account"
}

resource "google_project_iam_member" "confidential" {
  for_each = toset(local.confidential_project_roles)

  project = var.confidential_data_project_id
  role    = each.value
  member  = "serviceAccount:${module.dataflow_controller_service_account.email}"
}

resource "google_project_iam_member" "governance" {
  for_each = toset(local.governance_project_roles)

  project = var.data_governance_project_id
  role    = each.value
  member  = "serviceAccount:${module.dataflow_controller_service_account.email}"
}

resource "google_project_iam_member" "non_confidential" {
  for_each = toset(local.non_conf_project_roles)

  project = var.non_confidential_data_project_id
  role    = each.value
  member  = "serviceAccount:${module.dataflow_controller_service_account.email}"
}
