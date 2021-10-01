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

module "dataflow_controller_service_account" {
  source       = "terraform-google-modules/service-accounts/google"
  version      = "~> 3.0"
  project_id   = var.confidential_data_project_id
  names        = ["sa-dataflow-controller-reid"]
  display_name = "Cloud Dataflow controller service account"
  project_roles = [
    "${var.confidential_data_project_id}=>roles/pubsub.subscriber",
    "${var.confidential_data_project_id}=>roles/bigquery.admin",
    "${var.confidential_data_project_id}=>roles/cloudkms.admin",
    "${var.confidential_data_project_id}=>roles/cloudkms.cryptoKeyDecrypter",
    "${var.confidential_data_project_id}=>roles/dlp.admin",
    "${var.confidential_data_project_id}=>roles/dlp.deidentifyTemplatesEditor",
    "${var.confidential_data_project_id}=>roles/dlp.user",
    "${var.confidential_data_project_id}=>roles/storage.admin",
    "${var.confidential_data_project_id}=>roles/dataflow.serviceAgent",
    "${var.confidential_data_project_id}=>roles/dataflow.worker",
    "${var.confidential_data_project_id}=>roles/compute.viewer",
    "${var.confidential_data_project_id}=>roles/serviceusage.serviceUsageConsumer",
    "${var.non_confidential_project_id}=>roles/bigquery.admin",
    "${var.non_confidential_project_id}=>roles/serviceusage.serviceUsageConsumer",
    "${var.data_governance_project_id}=>roles/serviceusage.serviceUsageConsumer",
    "${var.data_governance_project_id}=>roles/dlp.admin",
    "${var.data_governance_project_id}=>roles/dlp.deidentifyTemplatesEditor",
    "${var.data_governance_project_id}=>roles/dlp.user",
    "${var.data_governance_project_id}=>roles/cloudkms.admin",
    "${var.data_governance_project_id}=>roles/cloudkms.cryptoKeyDecrypter"
  ]
}

