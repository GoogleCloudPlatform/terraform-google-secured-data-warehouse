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

module "data_governance_example" {
  source = "../..//modules/data_governance"

  project_id                = var.project_id
  terraform_service_account = var.terraform_service_account
  original_key_secret_name  = var.original_key_secret_name
  project_id_secret_mgr     = var.project_id_secret_mgr
  kms_location              = "us-east1"
  template_file             = "${path.module}/deidentification.tmpl"
}
