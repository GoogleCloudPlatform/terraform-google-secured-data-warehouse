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


module "dataflow_with_dlp" {
  source                          = "github.com/terraform-google-modules/terraform-google-dataflow/examples/dlp_api_example/"
  project_id                      = var.project_id
  region                          = var.region
  terraform_service_account_email = var.terraform_service_account
  service_account_email           = module.dataflow_controller_service_account.email
  key_ring                        = var.key_ring
  kms_key_name                    = var.kms_key_name
  wrapped_key                     = var.wrapped_key
  create_key_ring                 = var.create_key_ring
}
