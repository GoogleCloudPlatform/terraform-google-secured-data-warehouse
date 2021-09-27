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
  location                                   = "us-central1"
  docker_repository_id                       = "flex-templates"
  python_repository_id                       = "python-modules"
  project_id                                 = module.external_flex_template_project.project_id
  bucket_name                                = module.external_flex_template_infrastructure.flex_template_bucket_name
  java_de_identify_flex_template_image_tag   = "${local.location}-docker.pkg.dev/${local.project_id}/${local.docker_repository_id}/samples/regional-txt-dlp-bq-streaming:latest"
  java_de_identify_template_gs_path          = "gs://${local.bucket_name}/flex-template-samples/regional-txt-dlp-bq-streaming.json"
  java_re_identify_flex_template_image_tag   = "${local.location}-docker.pkg.dev/${local.project_id}/${local.docker_repository_id}/samples/regional-bq-dlp-bq-streaming:latest"
  java_re_identify_template_gs_path          = "gs://${local.bucket_name}/flex-template-samples/regional-bq-dlp-bq-streaming.json"
  pip_index_url                              = "https://${local.location}-python.pkg.dev/${local.project_id}/${local.python_repository_id}/simple/"
  python_de_identify_flex_template_image_tag = "${local.location}-docker.pkg.dev/${local.project_id}/${local.docker_repository_id}/samples/regional-python-dlp-flex:latest"
  python_de_identify_template_gs_path        = "gs://${local.bucket_name}/flex-template-samples/regional-python-dlp-flex.json"

  python_re_identify_flex_template_image_tag = "${local.location}-docker.pkg.dev/${local.project_id}/${local.docker_repository_id}/samples/regional_bq_dlp_bq_flex:latest"
  python_re_identify_template_gs_path        = "gs://${local.bucket_name}/flex-template-samples/regional_bq_dlp_bq_flex.json"

}

module "external_flex_template_infrastructure" {
  source = "../..//flex_templates/template-artifact-storage"

  project_id           = local.project_id
  location             = local.location
  docker_repository_id = local.docker_repository_id
  python_repository_id = local.python_repository_id

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

resource "null_resource" "java_de_identification_flex_template" {

  triggers = {
    project_id                = local.project_id
    terraform_service_account = google_service_account.int_ci_service_account.email
    template_image_tag        = local.java_de_identify_flex_template_image_tag
    template_gs_path          = local.java_de_identify_template_gs_path
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOF
      gcloud builds submit \
       --project=${local.project_id} \
       --config ${path.module}/../../flex_templates/java/regional_dlp_de_identification/cloudbuild.yaml \
       ${path.module}/../../flex_templates/java/regional_dlp_de_identification \
       --substitutions="_PROJECT=${local.project_id},_FLEX_TEMPLATE_IMAGE_TAG=${local.java_de_identify_flex_template_image_tag},_TEMPLATE_GS_PATH=${local.java_de_identify_template_gs_path}"
EOF

  }

  depends_on = [
    module.external_flex_template_infrastructure
  ]
}

resource "null_resource" "java_re_identification_flex_template" {

  triggers = {
    project_id                = local.project_id
    terraform_service_account = google_service_account.int_ci_service_account.email
    template_image_tag        = local.java_re_identify_flex_template_image_tag
    template_gs_path          = local.java_re_identify_template_gs_path
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOF
      gcloud builds submit \
       --project=${local.project_id} \
       --config ${path.module}/flex_templates/java/regional_dlp_re_identification/cloudbuild.yaml \
       ${path.module}/flex_templates/java/regional_dlp_re_identification \
       --substitutions="_PROJECT=${local.project_id},_FLEX_TEMPLATE_IMAGE_TAG=${local.java_re_identify_flex_template_image_tag},_TEMPLATE_GS_PATH=${local.java_re_identify_template_gs_path}"
EOF

  }

  depends_on = [
    module.external_flex_template_infrastructure
  ]
}

resource "null_resource" "python_de_identification_flex_template" {

  triggers = {
    project_id                = local.project_id
    terraform_service_account = google_service_account.int_ci_service_account.email
    template_image_tag        = local.python_de_identify_flex_template_image_tag
    template_gs_path          = local.python_de_identify_template_gs_path
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOF
      gcloud builds submit \
       --project=${local.project_id} \
       --config ${path.module}/../../flex_templates/python/regional_dlp_de_identification/cloudbuild.yaml \
       ${path.module}/../../flex_templates/python/regional_dlp_de_identification \
       --substitutions="_PROJECT=${local.project_id},_FLEX_TEMPLATE_IMAGE_TAG=${local.python_de_identify_flex_template_image_tag},_PIP_INDEX_URL=${local.pip_index_url},_TEMPLATE_GS_PATH=${local.python_de_identify_template_gs_path}"
EOF

  }

  depends_on = [
    module.external_flex_template_infrastructure
  ]
}

resource "null_resource" "python_re_identification_flex_template" {

  triggers = {
    project_id                = local.project_id
    terraform_service_account = google_service_account.int_ci_service_account.email
    template_image_tag        = local.python_re_identify_flex_template_image_tag
    template_gs_path          = local.python_re_identify_template_gs_path
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOF
      gcloud builds submit \
       --project=${local.project_id} \
       --config ${path.module}/../../flex_templates/python/regional_dlp_re_identification/cloudbuild.yaml \
       ${path.module}/../../flex_templates/python/regional_dlp_re_identification \
       --substitutions="_PROJECT=${local.project_id},_FLEX_TEMPLATE_IMAGE_TAG=${local.python_re_identify_flex_template_image_tag},_PIP_INDEX_URL=${local.pip_index_url},_TEMPLATE_GS_PATH=${local.python_re_identify_template_gs_path}"
EOF

  }

  depends_on = [
    module.external_flex_template_infrastructure
  ]
}

resource "null_resource" "upload_modules" {

  triggers = {
    project_id                = local.project_id
    repository_id             = local.python_repository_id
    location                  = local.location
    terraform_service_account = google_service_account.int_ci_service_account.email
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOF
     gcloud builds submit --project=${local.project_id} \
     --config ${path.module}/../../flex_templates/python/modules/cloudbuild.yaml \
     ${path.module}/../../flex_templates/python/modules \
     --substitutions=_REPOSITORY_ID=${local.python_repository_id},_DEFAULT_REGION=${local.location}
EOF

  }

  depends_on = [
    module.external_flex_template_infrastructure
  ]
}
