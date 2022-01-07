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
    "roles/pubsub.editor",
    "roles/storage.objectViewer",
    "roles/dataflow.worker",
    "roles/bigquery.jobUser",
    "roles/bigquery.dataEditor",
    "roles/serviceusage.serviceUsageConsumer"
  ]

  governance_project_roles = [
    "roles/dlp.user",
    "roles/dlp.inspectTemplatesReader",
    "roles/dlp.deidentifyTemplatesReader"
  ]

  non_confidential_data_project_roles = [
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser"
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

resource "google_service_account_iam_member" "terraform_sa_service_account_user" {
  service_account_id = module.dataflow_controller_service_account.service_account.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.terraform_service_account}"
}

resource "google_project_iam_member" "ingestion" {
  for_each = toset(local.data_ingestion_project_roles)

  project = var.data_ingestion_project_id
  role    = each.value
  member  = "serviceAccount:${module.dataflow_controller_service_account.email}"
}

resource "google_storage_bucket_iam_member" "objectAdmin" {
  bucket = module.dataflow_bucket.bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.dataflow_controller_service_account.email}"
}

resource "google_project_iam_member" "governance" {
  for_each = toset(local.governance_project_roles)

  project = var.data_governance_project_id
  role    = each.value
  member  = "serviceAccount:${module.dataflow_controller_service_account.email}"
}

resource "google_project_iam_member" "non_confidential" {
  for_each = toset(local.non_confidential_data_project_roles)

  project = var.non_confidential_data_project_id
  role    = each.value
  member  = "serviceAccount:${module.dataflow_controller_service_account.email}"
}

//service account for storage
resource "google_service_account" "storage_writer_service_account" {
  project      = var.data_ingestion_project_id
  account_id   = "sa-storage-writer"
  display_name = "Cloud Storage data writer service account"
}

resource "google_storage_bucket_iam_member" "objectCreator" {
  bucket = module.data_ingestion_bucket.bucket.name
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
  topic   = module.data_ingestion_topic.id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.pubsub_writer_service_account.email}"
}

//Cloud Scheduler service account
resource "google_service_account" "scheduler_controller_service_account" {
  project      = var.data_ingestion_project_id
  account_id   = "sa-scheduler-controller"
  display_name = "Cloud Scheduler controller service account"
}
