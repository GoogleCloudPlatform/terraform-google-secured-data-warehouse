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
  region = "us-central1"
}


module "batch_dataflow" {
  source                           = "../../../examples/batch-data-ingestion"
  org_id                           = var.org_id
  data_ingestion_project_id        = var.data_ingestion_project_id[0]
  data_governance_project_id       = var.data_governance_project_id[0]
  datalake_project_id              = var.datalake_project_id[0]
  privileged_data_project_id       = var.privileged_data_project_id[0]
  sdx_project_number               = var.sdx_project_number
  terraform_service_account        = var.terraform_service_account
  access_context_manager_policy_id = var.access_context_manager_policy_id
  network_self_link                = var.data_ingestion_network_self_link[0]
  subnetwork_self_link             = var.data_ingestion_subnets_self_link[0]
  delete_contents_on_destroy       = true
}
