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

data "google_service_account" "dataflow_service_account" {
  account_id = "sa-dataflow-controller"
  project    = var.project_id
}

data "google_compute_network" "vpc_network" {
  name    = "vpc-tst-network"
  project = var.project_id
}

resource "random_id" "random_suffix" {
  byte_length = 4
}

module "dataflow-with-dlp" {
  source                    = "../../../examples/dataflow-with-dlp"
  dataset_id                = "dts_test_int"
  project_id                = var.project_id
  bucket_name               = "tmp-dataflow"
  region                    = "us-central1"
  zone                      = "us-central1-a"
  key_ring                  = "kms_key_ring_${random_id.random_suffix.hex}"
  kms_key_name              = "kms_key_name_test_${random_id.random_suffix.hex}"
  bucket_force_destroy      = true
  bucket_location           = var.bucket_location
  terraform_service_account = var.terraform_service_account
  dataflow_service_account  = data.google_service_account.dataflow_service_account.email
  network_self_link         = data.google_compute_network.vpc_network.id
  subnetwork_self_link      = data.google_compute_network.vpc_network.subnetworks_self_links[0]
}
