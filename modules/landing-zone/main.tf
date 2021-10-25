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

//storage landing zone bucket
module "landing_zone_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.0"

  project_id      = var.landing_zone_project_id
  name            = "bkt-${var.landing_zone_project_id}-${var.bucket_name}-${random_id.suffix.hex}"
  location        = var.bucket_location
  storage_class   = var.bucket_class
  lifecycle_rules = var.bucket_lifecycle_rules
  force_destroy   = var.delete_contents_on_destroy

  encryption = {
    default_kms_key_name = var.landing_zone_encryption_key
  }

  labels = {
    "enterprise_landing_zone_bucket" = "true"
  }
}

module "dataflow_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.0"

  project_id    = var.landing_zone_project_id
  name          = "bkt-${var.landing_zone_project_id}-tmp-dataflow-${random_id.suffix.hex}"
  location      = var.bucket_location
  storage_class = "STANDARD"
  force_destroy = var.delete_contents_on_destroy


  encryption = {
    default_kms_key_name = var.landing_zone_encryption_key
  }

  labels = {
    "dataflow_landing_zone_bucket" = "true"
  }

}

//pub/sub landing zone topic
module "landing_zone_topic" {
  source  = "terraform-google-modules/pubsub/google"
  version = "~> 2.0"

  project_id             = var.landing_zone_project_id
  topic                  = "tpc-landing-zone-${random_id.suffix.hex}"
  topic_kms_key_name     = var.landing_zone_encryption_key
  message_storage_policy = { allowed_persistence_regions : [var.region] }
}

//BigQuery dataset
module "bigquery_dataset" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 5.2.0"

  project_id                  = var.non_confidential_data_project_id
  dataset_id                  = var.dataset_id
  dataset_name                = var.dataset_name
  description                 = var.dataset_description
  location                    = var.dataset_location
  encryption_key              = var.bigquery_encryption_key
  delete_contents_on_destroy  = var.delete_contents_on_destroy
  default_table_expiration_ms = var.dataset_default_table_expiration_ms

  dataset_labels = {
    purpose  = "landing-zone"
    billable = "true"
  }
}
