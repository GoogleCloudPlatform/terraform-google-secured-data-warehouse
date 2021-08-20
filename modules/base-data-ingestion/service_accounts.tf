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


//Dataflow controller service account
module "dataflow_controller_service_account" {
  source       = "terraform-google-modules/service-accounts/google"
  version      = "~> 3.0"
  project_id   = var.project_id
  names        = ["sa-dataflow-controller"]
  display_name = "Cloud Dataflow controller service account"
  project_roles = [
    "${var.project_id}=>roles/pubsub.subscriber",
    "${var.project_id}=>roles/bigquery.admin",
    "${var.project_id}=>roles/cloudkms.admin",
    "${var.project_id}=>roles/cloudkms.cryptoKeyDecrypter",
    "${var.project_id}=>roles/dlp.admin",
    "${var.project_id}=>roles/storage.admin",
    "${var.project_id}=>roles/dataflow.serviceAgent",
    "${var.project_id}=>roles/dataflow.worker",
    "${var.project_id}=>roles/compute.viewer",
  ]
}

//service account for storage
module "storage_writer_service_account" {
  source       = "terraform-google-modules/service-accounts/google"
  version      = "~> 3.0"
  project_id   = var.project_id
  names        = ["sa-storage-writer"]
  display_name = "Cloud Storage data writer service account"
}

//service account for Pub/sub
module "pubsub_writer_service_account" {
  source       = "terraform-google-modules/service-accounts/google"
  version      = "~> 3.0"
  project_id   = var.project_id
  names        = ["sa-pubsub-writer"]
  display_name = "Cloud PubSub data writer service account"
}
