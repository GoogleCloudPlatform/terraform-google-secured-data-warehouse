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
  version = "~> 1.7"

  project_id = var.project_id
  prefix     = "bkt-${random_id.suffix.hex}"
  names      = [var.bucket_name]
  location   = var.bucket_location

  labels = {
    "enterprise_data_ingest_bucket" = "true"
  }
}

//pub/sub ingest topic
module "data_ingest_topic" {
  source     = "terraform-google-modules/pubsub/google"
  version    = "~> 1.4"
  topic      = "tpc-data-ingest-${random_id.suffix.hex}"
  project_id = var.project_id
}

//BigQuery dataset
module "bigquery_dataset" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 4.4"

  project_id                  = var.project_id
  dataset_id                  = var.dataset_id
  dataset_name                = var.dataset_name
  description                 = var.dataset_description
  location                    = var.dataset_location
  default_table_expiration_ms = var.dataset_default_table_expiration_ms

  dataset_labels = {
    porpouse = "ingest"
    billable = "true"
  }
}
