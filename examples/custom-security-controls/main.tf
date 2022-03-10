/**
 * Copyright 2022 Google LLC
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
  confidential_data_project_id     = var.confidential_data_project_id
  non_confidential_data_project_id = var.non_confidential_data_project_id
  data_ingestion_project_id        = var.data_ingestion_project_id
  sdx_project_number               = var.sdx_project_number
  terraform_service_account        = var.terraform_service_account
  access_context_manager_policy_id = var.access_context_manager_policy_id
  bucket_name                      = "bucket_example"
  dataset_id                       = "dataset_example"
  cmek_keyring_name                = "key_name_example"
  pubsub_resource_location         = "us-east4"
  location                         = "us-east4"
  delete_contents_on_destroy       = var.delete_contents_on_destroy
  perimeter_additional_members     = var.perimeter_additional_members
  data_engineer_group              = var.data_engineer_group
  data_analyst_group               = var.data_analyst_group
  security_analyst_group           = var.security_analyst_group
  network_administrator_group      = var.network_administrator_group
  security_administrator_group     = var.security_administrator_group

  depends_on = [
    module.data_ingestion_project_id,
    module.data_governance_project_id,
    module.confidential_data_project_id,
    module.non_confidential_data_project_id,
    module.iam_projects,
    google_project_iam_binding.remove_owner_role
  ]
}
