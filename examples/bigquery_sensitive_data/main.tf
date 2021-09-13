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
  location   = "us-east1"
  dataset_id = "secured_dataset"
}
resource "random_id" "suffix" {
  byte_length = 4
}

module "bigquery_sensitive_data" {
  source                     = "../..//modules/data_warehouse_taxonomy"
  taxonomy_project_id        = var.taxonomy_project_id
  privileged_data_project_id = var.privileged_data_project_id
  non_sensitive_project_id   = var.non_sensitive_project_id
  taxonomy_name              = "secured_taxonomy"
  table_id                   = "sample_data"
  dataset_id                 = local.dataset_id
  location                   = local.location
  cmek_location              = local.location
  cmek_keyring_name          = "cmek_keyring_name_${random_id.suffix.hex}"
  delete_contents_on_destroy = var.delete_contents_on_destroy
}
