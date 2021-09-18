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
  flex_location = "us-central1"
  repository_id = "flex-templates"

  de_identify_flex_template_image_tag = "${local.flex_location}-docker.pkg.dev/${module.external_flex_template_project.project_id}/${local.repository_id}/samples/regional-txt-dlp-bq-streaming:latest"
  de_identify_template_gs_path        = "gs://${module.external_flex_template_infrastructure.flex_template_bucket_name}/flex-template-samples/regional-txt-dlp-bq-streaming.json"

  re_identify_flex_template_image_tag = "${local.flex_location}-docker.pkg.dev/${module.external_flex_template_project.project_id}/${local.repository_id}/samples/regional-bq-dlp-bq-streaming:latest"
  re_identify_template_gs_path        = "gs://${module.external_flex_template_infrastructure.flex_template_bucket_name}/flex-template-samples/regional-bq-dlp-bq-streaming.json"

}

module "external_flex_template_infrastructure" {
  source = "../..//flex_templates/infrastructure"

  project_id    = module.external_flex_template_project.project_id
  location      = local.flex_location
  repository_id = local.repository_id

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

resource "null_resource" "de_identification_flex_template" {

  triggers = {
    project_id                = module.external_flex_template_project.project_id
    terraform_service_account = google_service_account.int_ci_service_account.email
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOF
      gcloud builds submit \
       --project=${module.external_flex_template_project.project_id} \
       --config ${path.module}/../../flex_templates/java/regional_dlp_de_identification/cloudbuild.yaml \
       ${path.module}/../../flex_templates/java/regional_dlp_de_identification \
       --substitutions="_BUCKET=${module.external_flex_template_infrastructure.flex_template_bucket_name},_PROJECT=${module.external_flex_template_project.project_id},_FLEX_REPO_URL=${module.external_flex_template_infrastructure.flex_template_repository_url}" \
       --impersonate-service-account=${google_service_account.int_ci_service_account.email}
EOF

  }

  depends_on = [
    module.external_flex_template_infrastructure
  ]
}
