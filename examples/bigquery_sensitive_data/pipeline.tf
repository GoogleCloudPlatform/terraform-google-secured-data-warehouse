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
  dlp_location             = "us"
  enable_dataflow          = var.flex_template_gs_path != "" ? 1 : 0
}

module "de_identification_template_example" {
  source = "../..//modules/de_identification_template"

  project_id                = var.taxonomy_project_id
  terraform_service_account = var.terraform_service_account
  dataflow_service_account  = module.bigquery_sensitive_data.dataflow_controller_service_account_email
  crypto_key                = var.crypto_key
  wrapped_key               = var.wrapped_key
  dlp_location              = local.dlp_location
  template_file             = "${path.module}/templates/deidentification.tpl"
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
    default_kms_key_name = module.bigquery_sensitive_data.cmek_reidentification_crypto_key
  }
}

# flex template options: https://cloud.google.com/dataflow/docs/reference/pipeline-options#java
resource "google_dataflow_flex_template_job" "regional_dlp" {
  provider = google-beta

  count                   = local.enable_dataflow ? 1 : 0
  project                 = var.privileged_data_project_id
  name                    = "dataflow-flex-regional-dlp-job"
  container_spec_gcs_path = var.flex_template_gs_path
  region                  = local.location

  parameters = {
    inputBigQueryTable      = "${var.non_sensitive_project_id}:${local.non_sensitive_dataset_id}.sample_deid_data"
    outputBigQueryDataset   = local.dataset_id
    deidentifyTemplateName  = "projects/${var.taxonomy_project_id}/locations/${local.dlp_location}/deidentifyTemplates/${module.de_identification_template_example.template_id}"
    dlpLocation             = local.dlp_location
    dlpProjectId            = var.taxonomy_project_id
    privilegedDataProjectId = var.privileged_data_project_id
    serviceAccount          = module.bigquery_sensitive_data.dataflow_controller_service_account_email
    subnetwork              = var.subnetwork
    dataflowKmsKey          = module.bigquery_sensitive_data.cmek_reidentification_crypto_key
    tempLocation            = "${module.dataflow_bucket.bucket.url}/tmp/"
    stagingLocation         = "${module.dataflow_bucket.bucket.url}/staging/"
    usePublicIps            = false
    enableStreamingEngine   = true
  }
}
