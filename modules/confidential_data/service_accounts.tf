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
    "pubsub.subscriber",
    "bigquery.admin",
    "cloudkms.admin",
    "cloudkms.cryptoKeyDecrypter",
    "dlp.admin",
    "dlp.deidentifyTemplatesEditor",
    "dlp.user",
    "storage.admin",
    "dataflow.serviceAgent",
    "dataflow.worker",
    "compute.viewer",
    "serviceusage.serviceUsageConsumer"
  ]

  governance_project_roles = [
    "serviceusage.serviceUsageConsumer",
    "dlp.admin",
    "dlp.deidentifyTemplatesEditor",
    "dlp.user",
    "cloudkms.admin",
    "cloudkms.cryptoKeyDecrypter"
  ]

  non_conf_project_roles = [
    "bigquery.admin",
    "serviceusage.serviceUsageConsumer"
  ]
}

module "dataflow_controller_service_account" {
  source       = "terraform-google-modules/service-accounts/google"
  version      = "~> 3.0"
  project_id   = var.confidential_data_project_id
  names        = ["sa-dataflow-controller-reid"]
  display_name = "Cloud Dataflow controller service account"
  project_roles = concat(
    [for role in local.confidential_project_roles : "${var.confidential_data_project_id}=>roles/${role}"],
    [for role in local.governance_project_roles : "${var.data_governance_project_id}=>roles/${role}"],
    [for role in local.non_conf_project_roles : "${var.non_confidential_project_id}=>roles/${role}"]
  )
}

