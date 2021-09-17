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

module "dwh_networking" {
  source = ".//modules/dwh-networking"

  project_id = var.data_ingestion_project_id
  region     = var.region
  vpc_name   = var.vpc_ingestion_network_name
  subnet_ip  = var.subnet_ip
}

module "dwh_networking_privileged" {
  source = ".//modules/dwh-networking"

  project_id = var.privileged_data_project_id
  region     = var.region
  vpc_name   = var.vpc_reidentify_network_name
  subnet_ip  = var.subnet_ip
}
