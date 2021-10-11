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


module "simple_example" {
  source                           = "../../..//examples/simple_example"
  org_id                           = var.org_id
  data_governance_project_id       = var.data_governance_project_id[1]
  confidential_data_project_id     = var.confidential_data_project_id[1]
  datalake_project_id              = var.datalake_project_id[1]
  data_ingestion_project_id        = var.data_ingestion_project_id[1]
  sdx_project_number               = var.sdx_project_number
  terraform_service_account        = var.terraform_service_account
  access_context_manager_policy_id = var.access_context_manager_policy_id
  delete_contents_on_destroy       = true
  perimeter_additional_members     = []
}

resource "google_storage_bucket" "static-site" {
  name          = "image-store.com"
  location      = "EU"
  force_destroy = true

  uniform_bucket_level_access = false
}
