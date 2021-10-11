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

module "de_identification_template_example" {
  source = "../..//modules/de-identification-template"

  project_id                = var.project_id
  terraform_service_account = var.terraform_service_account
  dataflow_service_account  = var.dataflow_service_account
  crypto_key                = var.crypto_key
  wrapped_key               = var.wrapped_key
  dlp_location              = var.dlp_location
  template_file             = "${path.module}/deidentification.tmpl"
}
