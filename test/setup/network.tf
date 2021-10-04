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

module "dwh_networking_ingestion" {
  source = "../../modules/dwh-networking"

  for_each = local.project_groups

  project_id = module.data_ingestion_project[each.key].project_id
  region     = "us-east4"
  vpc_name   = "ingestion"
  subnet_ip  = "10.0.32.0/21"
}

module "dwh_networking_confidential" {
  source = "../../modules/dwh-networking"

  for_each = local.project_groups

  project_id = module.confidential_data_project[each.key].project_id
  region     = "us-east4"
  vpc_name   = "reidentify"
  subnet_ip  = "10.0.32.0/21"
}
