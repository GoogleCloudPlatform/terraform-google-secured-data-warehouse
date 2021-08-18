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
  bq_schema                   = "book:STRING, author:STRING"

  perimeter_additional_members = distinct(
    concat(
      ["serviceAccount:${google_project_service_identity.cloudbuild_sa.email}"],
      var.perimeter_additional_members
    )
  )

  apis_to_enable = [
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "pubsub.googleapis.com",
    "bigquery.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "dlp.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudbilling.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "dataflow.googleapis.com"
  ]
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "google_project_service" "apis_to_enable" {
  for_each = toset(local.apis_to_enable)

  project = var.project_id
  service = each.key
}

resource "google_project_service_identity" "cloudbuild_sa" {
  provider = google-beta

  project = var.project_id
  service = "cloudbuild.googleapis.com"

  depends_on = [
    google_project_service.apis_to_enable
  ]
}

module "data_ingestion" {
  source                           = "../..//modules/base-data-ingestion"
  bucket_name                      = "bkt-dlp-flex-ingest-${random_id.suffix.hex}"
  dataset_id                       = "dlp_flex_ingest"
  org_id                           = var.org_id
  project_id                       = var.project_id
  data_governance_project_id       = var.project_id
  terraform_service_account        = var.terraform_service_account
  access_context_manager_policy_id = var.access_context_manager_policy_id
  perimeter_additional_members     = local.perimeter_additional_members
  vpc_name                         = "dlp-flex-ingest"
  subnet_ip                        = "10.0.32.0/21"
  region                           = var.location
  dataset_location                 = var.location
  bucket_location                  = var.location
  cmek_location                    = var.location
  cmek_keyring_name                = "dlp_flex_ingest"

  depends_on = [
    google_project_service.apis_to_enable
  ]
}

module "de_identification_template_example" {
  source = "../..//modules/de_identification_template"

  project_id                = var.project_id
  terraform_service_account = var.terraform_service_account
  dataflow_service_account  = module.data_ingestion.dataflow_controller_service_account_email
  crypto_key                = var.crypto_key
  wrapped_key               = var.wrapped_key
  dlp_location              = var.location
  template_file             = "${path.module}/templates/deidentification.tpl"

}

module "flex_dlp_template" {
  source = "../..//modules/flex_template"

  project_id                  = var.project_id
  location                    = var.location
  repository_id               = local.flex_template_repository_id
  python_modules_private_repo = "https://${var.location}-python.pkg.dev/${var.project_id}/${local.python_repository_id}/simple/"
  terraform_service_account   = var.terraform_service_account
  image_name                  = "regional_dlp_flex"
  image_tag                   = "0.1.0"
  kms_key_name                = module.data_ingestion.cmek_ingestion_crypto_key
  read_access_members         = ["serviceAccount:${module.data_ingestion.dataflow_controller_service_account_email}"]

  template_files = {
    code_file         = "${path.module}/files/pubsub_dlp_bigquery.py"
    metadata_file     = "${path.module}/files/metadata.json"
    requirements_file = "${path.module}/files/requirements.txt"
  }

  module_depends_on = [
    google_project_service.apis_to_enable
  ]

}

module "python_module_repository" {
  source = "../..//modules/python_module_repository"

  project_id                = var.project_id
  location                  = var.location
  repository_id             = local.python_repository_id
  terraform_service_account = var.terraform_service_account
  requirements_filename     = "${path.module}/files/requirements.txt"
  read_access_members       = ["serviceAccount:${module.data_ingestion.dataflow_controller_service_account_email}"]

  module_depends_on = [
    google_project_service.apis_to_enable
  ]
}

module "dataflow_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.1"

  project_id         = var.project_id
  name               = "bkt-tmp-dataflow-${random_id.suffix.hex}"
  location           = var.location
  force_destroy      = true
  bucket_policy_only = true

  encryption = {
    default_kms_key_name = module.data_ingestion.cmek_ingestion_crypto_key
  }

  depends_on = [
    google_project_service.apis_to_enable
  ]
}

resource "google_dataflow_flex_template_job" "regional_dlp" {
  provider = google-beta

  project                 = var.project_id
  name                    = "dataflow-flex-regional-dlp-job"
  container_spec_gcs_path = module.flex_dlp_template.flex_template_gs_path
  region                  = var.location

  parameters = {
    input_topic                    = "projects/${var.project_id}/topics/${module.data_ingestion.data_ingest_topic_name}"
    deidentification_template_name = "projects/${var.project_id}/locations/${var.location}/deidentifyTemplates/${module.de_identification_template_example.template_id}"
    dlp_location                   = var.location
    dlp_project                    = var.project_id
    bq_schema                      = local.bq_schema
    output_table                   = "${var.project_id}:${module.data_ingestion.data_ingest_bigquery_dataset.dataset_id}.classical_books"
    service_account_email          = module.data_ingestion.dataflow_controller_service_account_email
    subnetwork                     = module.data_ingestion.subnets_self_links[0]
    dataflow_kms_key               = module.data_ingestion.cmek_ingestion_crypto_key
    temp_location                  = "${module.dataflow_bucket.bucket.url}/tmp/"
    no_use_public_ips              = "true"
  }

  depends_on = [
    module.de_identification_template_example,
    module.flex_dlp_template,
    module.python_module_repository
  ]
}
