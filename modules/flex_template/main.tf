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

/**
 * This module implements the creation of a Google Dataflow Python Flex Template based on the
 * official guide: https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates#python
 * and on an updated reference implementation for a streaming Python flex template
 * https://github.com/GoogleCloudPlatform/python-docs-samples/tree/master/dataflow/flex-templates/streaming_beam
 *
 * This implementation uses Google Artifact registry instead of Google Container Registry.
 * This implementation may change if the official recommendation changes.
 */

locals {
  flex_template_image_tag = "${var.location}-docker.pkg.dev/${var.project_id}/${var.repository_id}/${var.image_name}:${var.image_tag}"
  template_gs_path        = "${module.templates_bucket.bucket.url}/dataflow/flex_templates/${var.image_name}.json"
  metadata_file_md5       = filemd5(var.template_files.metadata_file)
  requirements_file_md5   = filemd5(var.template_files.requirements_file)
  code_file_md5           = filemd5(var.template_files.code_file)
}

/**
 * This is a collateral effect of the workaround, using 'module_depends_on', for issue
 * https://github.com/terraform-google-modules/terraform-google-gcloud/issues/82
 * This module uses "terraform-google-gcloud" to run some commands that depends on each other.
 * If this module is called with a regular 'depends_on' it fails with the error from issue #82 on the "terraform-google-gcloud" modules
 * So the workaround, creating a custom 'module_depends_on', had to be replicated in this module too.
 * When issue #82 is fixed and the workaround removed, this can also be removed.
 */

resource "null_resource" "module_depends_on" {
  count = length(var.module_depends_on) > 0 ? 1 : 0

  triggers = {
    value = length(var.module_depends_on)
  }
}

resource "random_id" "suffix" {
  byte_length = 2
}

resource "google_project_service_identity" "cloudbuild_sa" {
  provider = google-beta

  project = var.project_id
  service = "cloudbuild.googleapis.com"
}

resource "google_artifact_registry_repository" "flex_templates" {
  provider = google-beta
  count    = var.create_repository ? 1 : 0

  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  description   = var.repository_description
  format        = "DOCKER"

  depends_on = [
    null_resource.module_depends_on
  ]
}

resource "google_artifact_registry_repository_iam_member" "reader" {
  provider = google-beta
  count    = length(var.read_access_members)

  project    = var.project_id
  location   = var.location
  repository = var.repository_id
  role       = "roles/artifactregistry.reader"
  member     = var.read_access_members[count.index]

  depends_on = [
    null_resource.module_depends_on,
    google_artifact_registry_repository.flex_templates
  ]
}

resource "google_artifact_registry_repository_iam_member" "writer" {
  provider = google-beta

  project    = var.project_id
  location   = var.location
  repository = var.repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_project_service_identity.cloudbuild_sa.email}"

  depends_on = [
    null_resource.module_depends_on,
    google_artifact_registry_repository.flex_templates
  ]
}

resource "google_project_iam_member" "cloud_build_builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_project_service_identity.cloudbuild_sa.email}"
}

module "templates_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.1.0"

  project_id         = var.project_id
  location           = var.location
  name               = "bkt-${var.location}-${var.project_id}-tpl-${random_id.suffix.hex}"
  bucket_policy_only = true
  force_destroy      = true

  encryption = {
    default_kms_key_name = var.kms_key_name
  }

  depends_on = [
    null_resource.module_depends_on
  ]
}

resource "local_file" "dockerfile" {
  content = templatefile(
    "${path.module}/templates/Dockerfile.tpl", {
      python_modules_private_repo = var.python_modules_private_repo
    }
  )
  filename = "${path.module}/Dockerfile"
}

resource "local_file" "requirements_txt" {
  content  = file(var.template_files.requirements_file)
  filename = "${path.module}/requirements.txt"
}

resource "local_file" "python_code" {
  content  = file(var.template_files.code_file)
  filename = "${path.module}/flex_main.py"
}

resource "local_file" "metadata_json" {
  content  = file(var.template_files.metadata_file)
  filename = "${path.module}/metadata.json"
}

module "build_container_image" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.0"

  skip_download = true

  create_cmd_triggers = {
    requirements_file_md5 = local.requirements_file_md5
    code_file_md5         = local.code_file_md5
  }

  create_cmd_entrypoint = "gcloud"
  create_cmd_body       = <<EOF
    builds submit --project=${var.project_id} \
    --config ${path.module}/cloudbuild.yaml ${path.module} \
    --substitutions=_FLEX_TEMPLATE_IMAGE_TAG=${local.flex_template_image_tag} \
    --impersonate-service-account=${var.terraform_service_account}
EOF

  module_depends_on = [
    google_artifact_registry_repository_iam_member.writer
  ]

}

module "flex_template_builder" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.0"

  skip_download = true

  create_cmd_triggers = {
    metadata_file_md5     = local.metadata_file_md5
    requirements_file_md5 = local.requirements_file_md5
    code_file_md5         = local.code_file_md5
  }

  create_cmd_entrypoint = "gcloud"
  create_cmd_body       = <<EOF
      dataflow flex-template build ${local.template_gs_path} \
       --image "${local.flex_template_image_tag}" \
       --sdk-language "PYTHON" \
       --metadata-file "${path.module}/metadata.json" \
       --impersonate-service-account=${var.terraform_service_account}
EOF

  module_depends_on = [
    module.build_container_image
  ]

}
