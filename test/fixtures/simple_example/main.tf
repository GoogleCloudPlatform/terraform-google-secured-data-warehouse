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
  data_governance_project_id       = var.project_id
  project_id                       = var.project_id
  terraform_service_account        = var.terraform_service_account
  access_context_manager_policy_id = var.access_context_manager_policy_id
}

//workaround due to propagation issues
resource "time_sleep" "wait_90_seconds_for_vpc_sc_propagation" {
  depends_on = [module.simple_example]

  create_duration = "90s"
}
