/**
 * Copyright 2022 Google LLC
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
  apis_to_enable = [
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "cloudbilling.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
  docker_repository_url = "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.flex_templates.name}"
  python_repository_url = "${var.location}-python.pkg.dev/${var.project_id}/${google_artifact_registry_repository.python_modules.name}"
}


resource "google_project_service" "apis_to_enable" {
  for_each = toset(local.apis_to_enable)

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

resource "random_id" "suffix" {
  byte_length = 2
}

resource "google_project_service_identity" "cloudbuild_sa" {
  provider = google-beta

  project = var.project_id
  service = "cloudbuild.googleapis.com"

  depends_on = [
    google_project_service.apis_to_enable
  ]
}

resource "google_project_iam_member" "cloud_build_builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_project_service_identity.cloudbuild_sa.email}"
}

resource "google_artifact_registry_repository" "flex_templates" {
  provider = google-beta

  project       = var.project_id
  location      = var.location
  repository_id = var.docker_repository_id
  description   = "DataFlow Flex Templates"
  format        = "DOCKER"

  depends_on = [
    google_project_service.apis_to_enable
  ]
}

resource "google_artifact_registry_repository_iam_member" "docker_writer" {
  provider = google-beta

  project    = var.project_id
  location   = var.location
  repository = var.docker_repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_project_service_identity.cloudbuild_sa.email}"

  depends_on = [
    google_artifact_registry_repository.flex_templates
  ]
}

resource "google_artifact_registry_repository" "python_modules" {
  provider = google-beta

  project       = var.project_id
  location      = var.location
  repository_id = var.python_repository_id
  description   = "Repository for Python modules for Dataflow flex templates"
  format        = "PYTHON"
}

resource "google_artifact_registry_repository_iam_member" "python_writer" {
  provider = google-beta

  project    = var.project_id
  location   = var.location
  repository = var.python_repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_project_service_identity.cloudbuild_sa.email}"

  depends_on = [
    google_artifact_registry_repository.python_modules
  ]
}

resource "google_storage_bucket" "templates_bucket" {
  name     = "bkt-${var.project_id}-tpl-${random_id.suffix.hex}"
  location = var.location
  project  = var.project_id

  force_destroy               = true
  uniform_bucket_level_access = true

  depends_on = [
    google_project_service.apis_to_enable
  ]
}
