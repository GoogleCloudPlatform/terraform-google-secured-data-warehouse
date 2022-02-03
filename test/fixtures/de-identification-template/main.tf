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
  keyring                     = "keyring_kek"
  key_name                    = "key_name_kek"
  key_rotation_period_seconds = "2592000s"
  template_display_name       = "De-identification template using a KMS wrapped CMEK"
  template_description        = "De-identifies sensitive content defined in the template with a KMS wrapped CMEK."
  wrapped_key_secret_data     = chomp(data.google_secret_manager_secret_version.wrapped_key.secret_data)
  secret_name                 = "wrapped_key_de_identification"
  location                    = "us-east4"
}

module "kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 1.2"

  project_id           = var.data_governance_project_id[0]
  location             = local.location
  keyring              = local.keyring
  keys                 = [local.key_name]
  key_protection_level = "HSM"
  key_rotation_period  = local.key_rotation_period_seconds
  prevent_destroy      = false
}

resource "google_secret_manager_secret" "wrapped_key_secret" {
  provider = google-beta

  secret_id = local.secret_name
  project   = var.data_governance_project_id[0]

  replication {
    user_managed {
      replicas {
        location = local.location
      }
    }
  }
}

resource "null_resource" "wrapped_key" {

  triggers = {
    secret_id = google_secret_manager_secret.wrapped_key_secret.id
  }

  provisioner "local-exec" {
    command = <<EOF
    ${path.module}/../../../helpers/wrapped_key.sh \
    ${var.terraform_service_account} \
    ${module.kms.keys[local.key_name]} \
    ${google_secret_manager_secret.wrapped_key_secret.name} \
    ${var.data_governance_project_id[0]}
EOF
  }
}

data "google_secret_manager_secret_version" "wrapped_key" {
  project = var.data_governance_project_id[0]
  secret  = google_secret_manager_secret.wrapped_key_secret.id

  depends_on = [
    null_resource.wrapped_key
  ]
}

module "de_identification_template" {
  source = "../../..//modules/de-identification-template"

  project_id                = var.data_governance_project_id[0]
  template_display_name     = local.template_display_name
  template_description      = local.template_description
  terraform_service_account = var.terraform_service_account
  dataflow_service_account  = var.terraform_service_account
  crypto_key                = module.kms.keys[local.key_name]
  wrapped_key               = local.wrapped_key_secret_data
  template_file             = "${path.module}/deidentification.tmpl"
  dlp_location              = local.location
}
