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

resource "random_id" "suffix" {
  byte_length = 4
}

//storage ingest bucket
module "data_ingest_bucket" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "~> 2.0"

  project_id      = var.project_id
  prefix          = "bkt-${random_id.suffix.hex}"
  names           = [var.bucket_name]
  location        = var.bucket_location
  storage_class   = var.bucket_class
  lifecycle_rules = var.bucket_lifecycle_rules

  encryption_key_names = {
    (var.bucket_name) = module.cmek.keys[local.ingestion_key_name]
  }

  labels = {
    "enterprise_data_ingest_bucket" = "true"
  }

  # depends_on needed to wait for the KMS roles
  # to be granted to the Storage Service Account.
  depends_on = [
    module.cmek
  ]
}

//pub/sub ingest topic
module "data_ingest_topic" {
  source  = "terraform-google-modules/pubsub/google"
  version = "~> 2.0"

  project_id         = var.project_id
  topic              = "tpc-data-ingest-${random_id.suffix.hex}"
  topic_kms_key_name = module.cmek.keys[local.ingestion_key_name]

  # depends_on needed to wait for the KMS roles
  # to be granted to the PubSub Service Account.
  depends_on = [
    module.cmek
  ]
}

//BigQuery dataset
module "bigquery_dataset" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 5.1"

  project_id                  = var.project_id
  dataset_id                  = var.dataset_id
  dataset_name                = var.dataset_name
  description                 = var.dataset_description
  location                    = var.dataset_location
  encryption_key              = module.cmek.keys[local.bigquery_key_name]
  default_table_expiration_ms = var.dataset_default_table_expiration_ms

  dataset_labels = {
    purpose  = "ingest"
    billable = "true"
  }

  # depends_on needed to wait for the KMS roles
  # to be granted to the Bigquery Service Account.
  depends_on = [
    module.cmek
  ]
}
