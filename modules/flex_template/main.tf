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
  flex_template_image_tag = "${var.location}-docker.pkg.dev/${var.project_id}/${var.repository_id}/${var.image_name}:${var.image_tag}"
  template_gs_path        = "${module.templates.bucket.url}/dataflow/flex_templates/${var.image_name}.json"
  metadata_file_md5       = filemd5(var.template_files.metadata_file)
  requirements_file_md5   = filemd5(var.template_files.requirements_file)
  code_file_md5           = filemd5(var.template_files.code_file)
}

resource "null_resource" "module_depends_on" {
  count = length(var.module_depends_on) > 0 ? 1 : 0

  triggers = {
    value = length(var.module_depends_on)
  }
}

resource "random_id" "random_suffix" {
  byte_length = 2
}

resource "google_artifact_registry_repository" "flex-repository" {
  provider = google-beta
  count    = var.create_flex_repository ? 1 : 0

  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  description   = var.repository_description
  format        = "DOCKER"

  depends_on = [
    null_resource.module_depends_on
  ]
}

resource "google_artifact_registry_repository_iam_member" "flex-template-iam" {
  provider = google-beta
  count    = length(var.read_access_members)

  project    = var.project_id
  location   = var.location
  repository = var.repository_id
  role       = "roles/artifactregistry.reader"
  member     = var.read_access_members[count.index]

  depends_on = [
    null_resource.module_depends_on,
    google_artifact_registry_repository.flex-repository
  ]
}

module "cloud-build-logs" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.1.0"

  project_id         = var.project_id
  location           = var.location
  name               = "bkt-${var.location}-${var.project_id}-cb-logs-${random_id.random_suffix.hex}"
  bucket_policy_only = true
  force_destroy      = true

  encryption = {
    default_kms_key_name = var.kms_key_name
  }

  depends_on = [
    null_resource.module_depends_on,
    google_artifact_registry_repository.flex-repository
  ]
}

module "templates" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.1.0"

  project_id         = var.project_id
  location           = var.location
  name               = "bkt-${var.location}-${var.project_id}-tpl-${random_id.random_suffix.hex}"
  bucket_policy_only = true
  force_destroy      = true

  encryption = {
    default_kms_key_name = var.kms_key_name
  }

  depends_on = [
    null_resource.module_depends_on
  ]
}

resource "local_file" "docker-file" {
  content = templatefile(
    "${path.module}/Dockerfile.tpl", {
      python_modules_private_repo = var.python_modules_private_repo
    }
  )
  filename = "${path.module}/Dockerfile"
}

resource "local_file" "requirements-file" {
  content  = file(var.template_files.requirements_file)
  filename = "${path.module}/requirements.txt"
}

resource "local_file" "code-file" {
  content  = file(var.template_files.code_file)
  filename = "${path.module}/flex_main.py"
}

resource "local_file" "metadata-file" {
  content  = file(var.template_files.metadata_file)
  filename = "${path.module}/metadata.json"
}

module "build-container-image" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.0"

  skip_download = true

  create_cmd_triggers = {
    requirements_file_md5 = local.requirements_file_md5
    code_file_md5         = local.code_file_md5
  }

  create_cmd_entrypoint = "gcloud"
  create_cmd_body       = <<EOF
    builds submit \
    --tag="${local.flex_template_image_tag}" ${path.module} \
    --project=${var.project_id} \
    --gcs-log-dir=${module.cloud-build-logs.bucket.url}/build-logs \
    --impersonate-service-account=${var.terraform_service_account}
EOF

  module_depends_on = [
    module.cloud-build-logs
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
    module.build-container-image
  ]

}
