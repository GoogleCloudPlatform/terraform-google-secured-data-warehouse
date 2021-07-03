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
  kms_roles            = toset(["roles/cloudkms.cryptoKeyEncrypter", "roles/cloudkms.cryptoKeyDecrypter"])
  template_id          = "${var.template_id_prefix}_${random_id.random_template_id_suffix.hex}"
  template_file_sha256 = filesha256(var.template_file)

  de_identification_template = templatefile(
    var.template_file,
    {
      crypto_key   = var.crypto_key,
      wrapped_key  = var.wrapped_key,
      template_id  = local.template_id,
      display_name = var.template_display_name,
      description  = var.template_description
    }
  )
}

resource "random_id" "random_template_id_suffix" {
  byte_length = 8

  keepers = {
    crypto_key      = var.crypto_key,
    wrapped_key     = var.wrapped_key,
    template_sha256 = local.template_file_sha256
  }
}

resource "google_kms_crypto_key_iam_binding" "dlp_encrypters_decrypters" {
  for_each = local.kms_roles

  role          = each.key
  crypto_key_id = var.crypto_key
  members       = ["serviceAccount:${var.dataflow_service_account}"]
}

module "de_identify_template" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.0"

  skip_download = true

  create_cmd_entrypoint = "curl"
  create_cmd_body       = <<EOF
    -s https://dlp.googleapis.com/v2/projects/${var.project_id}/locations/${var.dlp_location}/deidentifyTemplates \
    --header "X-Goog-User-Project: ${var.project_id}" \
    --header "Authorization: Bearer $(gcloud auth print-access-token --impersonate-service-account=${var.terraform_service_account})" \
    --header 'Accept: application/json' \
    --header "Content-Type: application/json" \
    --data '${local.de_identification_template}'
EOF

  destroy_cmd_entrypoint = "curl"
  destroy_cmd_body       = <<EOF
    -s --request DELETE \
    https://dlp.googleapis.com/v2/projects/${var.project_id}/locations/${var.dlp_location}/deidentifyTemplates/${local.template_id} \
    --header "X-Goog-User-Project: ${var.project_id}" \
    --header "Authorization: Bearer $(gcloud auth print-access-token --impersonate-service-account=${var.terraform_service_account})" \
    --header 'Accept: application/json' \
    --header "Content-Type: application/json"
EOF

}
