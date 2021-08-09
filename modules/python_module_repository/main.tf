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

resource "null_resource" "module_depends_on" {
  count = length(var.module_depends_on) > 0 ? 1 : 0

  triggers = {
    value = length(var.module_depends_on)
  }
}

resource "google_artifact_registry_repository" "python-modules" {
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

resource "google_artifact_registry_repository_iam_member" "python-registry-iam" {
  provider = google-beta
  count    = length(var.read_access_members)

  project    = var.project_id
  location   = var.location
  repository = var.repository_id
  role       = "roles/artifactregistry.reader"
  member     = var.read_access_members[count.index]

  depends_on = [
    null_resource.module_depends_on,
    google_artifact_registry_repository.python-modules
  ]
}

resource "local_file" "requirements-file" {
  content  = file(var.requirements_filename)
  filename = "${path.module}/requirements.txt"
}


module "upload_modules" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.0"

  skip_download = true

  create_cmd_entrypoint = "pip3"
  create_cmd_body       = <<EOF
    install --no-cache-dir twine keyrings.google-artifactregistry-auth
    mkdir -p ${local.temp_folder}
    # Download modules
    pip3 download --dest=${local.temp_folder} -r ${path.module}/requirements.txt --no-deps --no-binary=:all:
    pip3 download --dest=${local.temp_folder} apache-beam==${local.apache_beam_version} --no-deps --no-binary=:all:
    pip3 download --dest=${local.temp_folder} apache-beam==${local.apache_beam_version} --no-deps --only-binary=:all: \
    --python-version=37 --implementation=cp --abi=cp37m --platform=manylinux1_x86_64
    # Unzip Apache-beam modules
    unzip -q ${local.temp_folder}/apache-beam-${local.apache_beam_version}.zip  -d ${local.temp_folder}
    #Tar.gz Apache-beam modules
    tar -C ${local.temp_folder}/  -czf /${local.temp_folder}/apache-beam-${local.apache_beam_version}.tar.gz apache-beam-${local.apache_beam_version}
    # Remove temp data
    rm -rf ${local.temp_folder}/apache-beam-${local.apache_beam_version}.zip ${local.temp_folder}/apache-beam-${local.apache_beam_version}
    # Upload to private registry
    for python_module in "${local.temp_folder}"/*
    do
     twine upload --repository-url ${local.python_repository_url} "$python_module" || true
    done

EOF

  module_depends_on = [
    google_artifact_registry_repository.python-modules
  ]

}
