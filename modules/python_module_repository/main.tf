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
  python_repository_url = "https://${var.location}-python.pkg.dev/${var.project_id}/${var.repository_id}/"
  temp_folder           = "/tmp/artifact_registry_rep_${random_id.suffix.hex}"
  apache_beam_version   = "2.30.0"
}

resource "random_id" "suffix" {
  byte_length = 2
}

data "google_project" "cloudbuild_project" {
  project_id = var.project_id
}

resource "null_resource" "module_depends_on" {
  count = length(var.module_depends_on) > 0 ? 1 : 0

  triggers = {
    value = length(var.module_depends_on)
  }
}

resource "google_artifact_registry_repository" "python_modules" {
  provider = google-beta
  count    = var.create_repository ? 1 : 0

  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  description   = var.repository_description
  format        = "PYTHON"

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
    google_artifact_registry_repository.python_modules
  ]
}

resource "google_artifact_registry_repository_iam_member" "writer" {
  provider = google-beta

  project    = var.project_id
  location   = var.location
  repository = var.repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${data.google_project.cloudbuild_project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [
    null_resource.module_depends_on,
    google_artifact_registry_repository.python_modules
  ]
}


resource "google_project_iam_member" "cloud_build_builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${data.google_project.cloudbuild_project.number}@cloudbuild.gserviceaccount.com"
}


resource "local_file" "requirements_file" {
  content  = file(var.requirements_filename)
  filename = "${path.module}/requirements.txt"
}


module "upload_modules" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.0"

  skip_download = true

  create_cmd_entrypoint = "gcloud"
  create_cmd_body       = <<EOF
    builds submit --project=${var.project_id} \
    --config ${path.module}/cloudbuild.yaml ${path.module} \
    --substitutions=_REPOSITORY_ID=${var.repository_id},_DEFAULT_REGION=${var.location} \
    --impersonate-service-account=${var.terraform_service_account}

EOF

  module_depends_on = [
    google_artifact_registry_repository.python_modules
  ]

}
