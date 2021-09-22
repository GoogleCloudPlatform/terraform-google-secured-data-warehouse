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
  non_sensitive_dataset_id = "non_sensitive_dataset"

  # script for user:
  # assume schema is a json template with the correct variable
  # cat schema.json | jq -j  '.[] | "\(.name):\(.type),"'
  bq_schema = "name:STRING, gender:STRING, social_security_number:STRING"
}

module "de_identification_template_example" {
  source = "../..//modules/de_identification_template"

  project_id                = var.data_governance_project_id
  terraform_service_account = var.terraform_service_account
  dataflow_service_account  = module.secured_data_warehouse.confidential_dataflow_controller_service_account_email
  crypto_key                = var.crypto_key
  wrapped_key               = var.wrapped_key
  dlp_location              = local.location
  template_file             = "${path.module}/templates/deidentification.tpl"
}

resource "google_artifact_registry_repository_iam_member" "confidential_docker_reader" {
  provider = google-beta

  project    = var.external_flex_template_project_id
  location   = local.location
  repository = "flex-templates"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse.confidential_dataflow_controller_service_account_email}"

  depends_on = [
    module.secured_data_warehouse
  ]
}

resource "google_artifact_registry_repository_iam_member" "confidential_python_reader" {
  provider = google-beta

  project    = var.external_flex_template_project_id
  location   = local.location
  repository = "python-modules"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse.confidential_dataflow_controller_service_account_email}"

  depends_on = [
    module.secured_data_warehouse
  ]
}

resource "google_dataflow_flex_template_job" "regional_dlp" {
  provider = google-beta

  project                 = var.privileged_data_project_id
  name                    = "regional-flex-python-bq-dlp-bq"
  container_spec_gcs_path = var.flex_template_gs_path
  region                  = local.location

  parameters = {
    input_table                    = "${var.non_sensitive_project_id}:${local.non_sensitive_dataset_id}.sample_deid_data"
    deidentification_template_name = "${module.de_identification_template_example.template_full_path}"
    dlp_location                   = local.location
    dlp_project                    = var.data_governance_project_id
    bq_schema                      = local.bq_schema
    output_table                   = "${var.privileged_data_project_id}:${local.dataset_id}.sample_data"
    service_account_email          = module.secured_data_warehouse.confidential_dataflow_controller_service_account_email
    subnetwork                     = var.subnetwork_self_link
    dataflow_kms_key               = module.secured_data_warehouse.cmek_reidentification_crypto_key
    temp_location                  = "gs://${module.secured_data_warehouse.confidential_data_dataflow_bucket_name}/tmp/"
    staging_location               = "gs://${module.secured_data_warehouse.confidential_data_dataflow_bucket_name}/staging/"
    no_use_public_ips              = "true"
  }

  depends_on = [
    google_artifact_registry_repository_iam_member.confidential_docker_reader,
    google_artifact_registry_repository_iam_member.confidential_python_reader
  ]
}
