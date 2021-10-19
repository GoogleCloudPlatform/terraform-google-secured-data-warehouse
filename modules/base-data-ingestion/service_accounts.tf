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
  data_ingestion_project_roles = [
    "roles/pubsub.subscriber",
    "roles/storage.admin",
    "roles/dataflow.serviceAgent",
    "roles/dataflow.worker",
    "roles/compute.viewer"
  ]

  governance_project_roles = [
    "roles/cloudkms.admin",
    "roles/cloudkms.cryptoKeyDecrypter",
    "roles/dlp.admin"
  ]

  datalake_project_roles = [
    "roles/bigquery.admin",
    "roles/serviceusage.serviceUsageConsumer"
  ]
}

//Dataflow controller service account
module "dataflow_controller_service_account" {
  source       = "terraform-google-modules/service-accounts/google"
  version      = "~> 3.0"
  project_id   = var.data_ingestion_project_id
  names        = ["sa-dataflow-controller"]
  display_name = "Cloud Dataflow controller service account"
}


resource "google_project_iam_member" "ingestion" {
  for_each = toset(local.data_ingestion_project_roles)

  project = var.data_ingestion_project_id
  role    = each.value
  member  = "serviceAccount:${module.dataflow_controller_service_account.email}"
}

resource "google_project_iam_member" "governance" {
  for_each = toset(local.governance_project_roles)

  project = var.data_governance_project_id
  role    = each.value
  member  = "serviceAccount:${module.dataflow_controller_service_account.email}"
}

resource "google_project_iam_member" "datalake" {
  for_each = toset(local.datalake_project_roles)

  project = var.datalake_project_id
  role    = each.value
  member  = "serviceAccount:${module.dataflow_controller_service_account.email}"
}

//service account for storage
resource "google_service_account" "storage_writer_service_account" {
  project      = var.data_ingestion_project_id
  account_id   = "sa-storage-writer"
  display_name = "Cloud Storage data writer service account"
}

resource "google_storage_bucket_iam_member" "objectViewer" {
  bucket = module.data_ingest_bucket.bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.storage_writer_service_account.email}"
}

resource "google_storage_bucket_iam_member" "objectCreator" {
  bucket = module.data_ingest_bucket.bucket.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.storage_writer_service_account.email}"
}

//service account for Pub/sub
resource "google_service_account" "pubsub_writer_service_account" {
  project      = var.data_ingestion_project_id
  account_id   = "sa-pubsub-writer"
  display_name = "Cloud PubSub data writer service account"
}

resource "google_pubsub_topic_iam_member" "publisher" {
  project = var.data_ingestion_project_id
  topic   = module.data_ingest_topic.id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.pubsub_writer_service_account.email}"
}

resource "google_pubsub_topic_iam_member" "subscriber" {
  project = var.data_ingestion_project_id
  topic   = module.data_ingest_topic.id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.pubsub_writer_service_account.email}"
}
