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
  keyring  = "keyring_kek"
  key_name = "key_name_kek"
}

module "kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 1.2"

  project_id      = var.project_id
  location        = "us-east1"
  keyring         = local.keyring
  keys            = [local.key_name]
  prevent_destroy = false
}

resource "random_password" "original_dlp_key" {
  length  = 32
  special = false
}

resource "google_kms_secret_ciphertext" "wrapped_key" {
  crypto_key = module.kms.keys[local.key_name]
  plaintext  = base64encode(random_password.original_dlp_key.result)
}

module "de_identification_template" {
  source = "../../..//modules/de_identification_template"

  project_id                = var.project_id
  terraform_service_account = var.terraform_service_account
  crypto_key                = module.kms.keys[local.key_name]
  wrapped_key               = google_kms_secret_ciphertext.wrapped_key.ciphertext
  dlp_location              = "us-east1"
  template_file             = "${path.module}/deidentification.tmpl"
}
