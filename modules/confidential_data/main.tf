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

module "dataflow_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.0"

  project_id    = var.privileged_data_project_id
  name          = "bkt-${var.privileged_data_project_id}-tmp-dataflow-${random_id.suffix.hex}"
  location      = var.location
  storage_class = "STANDARD"
  force_destroy = var.delete_contents_on_destroy


  encryption = {
    default_kms_key_name = var.cmek_reidentification_crypto_key
  }

  labels = {
    "dataflow_data_ingest_bucket" = "true"
  }

}

module "bigquery_confidential_data" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 5.2.0"

  dataset_id                  = var.dataset_id
  description                 = "Dataset for BigQuery Sensitive Data"
  project_id                  = var.privileged_data_project_id
  location                    = var.location
  delete_contents_on_destroy  = var.delete_contents_on_destroy
  encryption_key              = var.cmek_confidential_bigquery_crypto_key
  default_table_expiration_ms = var.dataset_default_table_expiration_ms
  dataset_labels              = var.dataset_labels
}
