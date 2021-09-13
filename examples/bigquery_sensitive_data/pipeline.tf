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
  python_repository_id        = "python-modules"
  flex_template_repository_id = "flex-templates"
  non_sensitive_dataset_id    = "non_sensitive_dataset"
  dlp_location                = "us"

  # script for user:
  # assume schema is a json template with the correct variable
  # cat schema.json | jq -j  '.[] | "\(.name):\(.type),"'
  bq_schema = "name:STRING, gender:STRING, social_security_number:STRING"
}

resource "google_project_service_identity" "cloudbuild_sa" {
  provider = google-beta

  project = var.privileged_data_project_id
  service = "cloudbuild.googleapis.com"
}

module "de_identification_template_example" {
  source = "../..//modules/de_identification_template"

  project_id                = var.taxonomy_project_id
  terraform_service_account = var.terraform_service_account
  dataflow_service_account  = module.bigquery_sensitive_data.dataflow_controller_service_account_email
  crypto_key                = var.crypto_key
  wrapped_key               = var.wrapped_key
  dlp_location              = local.dlp_location #TODO this location is really dependant on the location of the CMEK key
  template_file             = "${path.module}/templates/deidentification.tpl"
}

module "flex_dlp_template" {
  source = "../..//modules/flex_template"

  project_id                  = var.privileged_data_project_id
  location                    = local.location
  repository_id               = local.flex_template_repository_id
  python_modules_private_repo = "https://${local.location}-python.pkg.dev/${var.privileged_data_project_id}/${local.python_repository_id}/simple/"
  terraform_service_account   = var.terraform_service_account
  image_name                  = "regional_dlp_flex"
  image_tag                   = "0.1.0"
  kms_key_name                = module.bigquery_sensitive_data.cmek_ingestion_crypto_key
  read_access_members         = ["serviceAccount:${module.bigquery_sensitive_data.dataflow_controller_service_account_email}"]

  template_files = {
    code_file         = "${path.module}/files/bigquery_dlp_bigquery.py"
    metadata_file     = "${path.module}/files/metadata.json"
    requirements_file = "${path.module}/files/requirements.txt"
  }
}

module "python_module_repository" {
  source = "../..//modules/python_module_repository"

  project_id                = var.privileged_data_project_id
  location                  = local.location
  repository_id             = local.python_repository_id
  terraform_service_account = var.terraform_service_account
  requirements_filename     = "${path.module}/files/requirements.txt"
  read_access_members       = ["serviceAccount:${module.bigquery_sensitive_data.dataflow_controller_service_account_email}"]

}

module "dataflow_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.1"

  project_id         = var.privileged_data_project_id
  name               = "bkt-tmp-dataflow-${random_id.suffix.hex}"
  location           = local.location
  force_destroy      = true
  bucket_policy_only = true

  encryption = {
    default_kms_key_name = module.bigquery_sensitive_data.cmek_ingestion_crypto_key
  }
}

resource "google_dataflow_flex_template_job" "regional_dlp" {
  provider = google-beta

  project                 = var.privileged_data_project_id
  name                    = "dataflow-flex-regional-dlp-job"
  container_spec_gcs_path = module.flex_dlp_template.flex_template_gs_path
  region                  = local.location

  parameters = {
    input_table                    = "${var.non_sensitive_project_id}:${local.non_sensitive_dataset_id}.sample_deid_data"
    deidentification_template_name = "projects/${var.taxonomy_project_id}/locations/${local.dlp_location}/deidentifyTemplates/${module.de_identification_template_example.template_id}"
    dlp_location                   = local.dlp_location
    dlp_project                    = var.taxonomy_project_id
    bq_schema                      = local.bq_schema
    output_table                   = "${var.privileged_data_project_id}:${local.dataset_id}.sample_data"
    service_account_email          = module.bigquery_sensitive_data.dataflow_controller_service_account_email
    subnetwork                     = var.subnetwork
    dataflow_kms_key               = module.bigquery_sensitive_data.cmek_ingestion_crypto_key
    temp_location                  = "${module.dataflow_bucket.bucket.url}/tmp/"
    no_use_public_ips              = "true"
  }

  depends_on = [
    module.de_identification_template_example,
    module.flex_dlp_template,
    module.python_module_repository,
    module.bigquery_sensitive_data
  ]
}
