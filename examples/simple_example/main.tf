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

module "secured_data_warehouse" {
  source                           = "../.."
  org_id                           = var.org_id
  data_governance_project_id       = var.data_governance_project_id
  privileged_data_project_id       = var.privileged_data_project_id
  datalake_project_id              = var.datalake_project_id
  data_ingestion_project_id        = var.data_ingestion_project_id
  terraform_service_account        = var.terraform_service_account
  access_context_manager_policy_id = var.access_context_manager_policy_id
  bucket_name                      = "bucket_simple_exemple"
  dataset_id                       = "dataset_simple_exemple"
  #vpc_name                         = "vpc-simple-exemple"
  cmek_keyring_name          = "key_name_simple_exemple"
  subnet_ip                  = "10.0.32.0/21"
  delete_contents_on_destroy = var.delete_contents_on_destroy
}
