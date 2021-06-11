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
  template_prefix      = var.template_prefix != "" ? var.template_prefix : "sbp_deidentification"
  template_id          = "${local.template_prefix}_${random_id.random_template_id_suffix.hex}"
  template_file_sha256 = filesha256(var.template_file)
  deidentification_template = templatefile(
    var.template_file,
    {
      crypto_key  = module.kms_dlp_tkek.keys[var.dlp_tkek_key_name],
      wrapped_key = google_kms_secret_ciphertext.kms_wrapped_dlp_key.ciphertext,
      template_id = local.template_id
    }
  )
}

resource "random_id" "random_template_id_suffix" {
  keepers = {
    crypto_key      = module.kms_dlp_tkek.keys[var.dlp_tkek_key_name],
    wrapped_key     = google_kms_secret_ciphertext.kms_wrapped_dlp_key.ciphertext
    template_sha256 = local.template_file_sha256
  }

  byte_length = 8
}

resource "random_password" "original_dlp_key" {
  length  = 32
  special = false
}

data "google_project" "dlp_project" {
  project_id = var.project_id
}

// https://cloud.google.com/dlp/docs/iam-permissions#service_account
resource "null_resource" "initalize_dlp_service_account" {
  provisioner "local-exec" {
    command = <<EOF
    curl -s --request POST \
    "https://dlp.googleapis.com/v2/projects/${var.project_id}/locations/us-central1/content:inspect" \
    --header "X-Goog-User-Project: ${var.project_id}" \
    --header "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --data '{"item":{"value":"google@google.com"}}' \
    --compressed
EOF

  }
}

resource "google_kms_secret_ciphertext" "kms_wrapped_dlp_key" {
  crypto_key = module.kms_dlp_tkek.keys[var.dlp_tkek_key_name]
  plaintext  = random_password.original_dlp_key.result
}

// KMS
module "kms_dlp_tkek" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 1.2"

  project_id         = var.project_id
  location           = "global"
  keyring            = var.dlp_tkek_keyring_name
  keys               = [var.dlp_tkek_key_name]
  encrypters         = ["serviceAccount:service-${data.google_project.dlp_project.number}@dlp-api.iam.gserviceaccount.com"]
  set_encrypters_for = [var.dlp_tkek_key_name]
  decrypters         = ["serviceAccount:service-${data.google_project.dlp_project.number}@dlp-api.iam.gserviceaccount.com"]
  set_decrypters_for = [var.dlp_tkek_key_name]
  prevent_destroy    = false
}

resource "null_resource" "deidentification_template_setup" {

  triggers = {
    template    = local.deidentification_template,
    project_id  = var.project_id,
    template_id = local.template_id
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOF
    curl -s https://dlp.googleapis.com/v2/projects/${var.project_id}/deidentifyTemplates \
    --header "X-Goog-User-Project: ${var.project_id}" \
    --header "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
    --header 'Accept: application/json' \
    --header "Content-Type: application/json" \
    --data '${local.deidentification_template}'
EOF

  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
    curl -s --request DELETE \
    https://dlp.googleapis.com/v2/projects/${self.triggers.project_id}/deidentifyTemplates/${self.triggers.template_id} \
    --header "X-Goog-User-Project: ${self.triggers.project_id}" \
    --header "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
    --header 'Accept: application/json' \
    --header "Content-Type: application/json"
EOF

  }

}
