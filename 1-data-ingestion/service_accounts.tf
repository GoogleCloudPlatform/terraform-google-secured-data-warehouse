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
  source = "..//modules/service_account"

  project_id   = var.project_id
  account_id   = "sa-dataflow-${random_id.suffix.hex}"
  display_name = "Cloud Dataflow controller service account"

  project_roles = [
    "roles/dataflow.worker",
    "roles/pubsub.admin",
    "roles/storage.admin",
    "roles/bigquery.admin",
    "roles/cloudkms.admin",
    "roles/dlp.admin",
    "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  ]

}

//service account for storage
module "storage_writer_service_account" {
  source = "..//modules/service_account"

  project_id   = var.project_id
  account_id   = "sa-storage-writer-${random_id.suffix.hex}"
  display_name = "Cloud Storage data writer service account"

  project_roles = [
    "roles/pubsub.admin"
  ]
}

//service account for Pub/sub
module "pubsub_writer_service_account" {
  source = "..//modules/service_account"

  project_id   = var.project_id
  account_id   = "sa-pubsub-writer-${random_id.suffix.hex}"
  display_name = "Cloud PubSub data writer service account"

  project_roles = [
    "roles/storage.admin"
  ]
}
