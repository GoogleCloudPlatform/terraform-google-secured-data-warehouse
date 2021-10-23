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
  location                    = "us-east4"
  non_confidential_dataset_id = "non_confidential_dataset"
  confidential_dataset_id     = "secured_dataset"
  taxonomy_display_name       = "${var.taxonomy_name}-${random_id.suffix.hex}"
  confidential_table_id       = "${trimsuffix(local.cc_file_name, ".csv")}_re_id"
  kek_keyring                 = "kek_keyring_${random_id.suffix.hex}"
  kek_key_name                = "kek_key_${random_id.suffix.hex}"
  cc_file_name                = "cc_100_records.csv"

}

resource "random_id" "suffix" {
  byte_length = 4
}

module "kek" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 1.2"

  project_id      = module.base_projects.data_governance_project_id
  location        = local.location
  keyring         = local.kek_keyring
  keys            = [local.kek_key_name]
  prevent_destroy = false
}

resource "random_id" "original_key" {
  byte_length = 16
}

// TODO: Replace with a method that does not store the plain value in the state
resource "google_kms_secret_ciphertext" "wrapped_key" {
  crypto_key = module.kek.keys[local.kek_key_name]
  plaintext  = random_id.original_key.b64_std
}

module "secured_data_warehouse" {
  source = "../.."

  org_id                           = var.org_id
  data_governance_project_id       = module.base_projects.data_governance_project_id
  confidential_data_project_id     = module.base_projects.confidential_data_project_id
  non_confidential_data_project_id = module.base_projects.non_confidential_data_project_id
  landing_zone_project_id          = module.base_projects.landing_zone_project_id
  sdx_project_number               = module.template_project.sdx_project_number
  terraform_service_account        = var.terraform_service_account
  access_context_manager_policy_id = var.access_context_manager_policy_id
  bucket_name                      = "landing-zone"
  location                         = local.location
  dataset_id                       = local.non_confidential_dataset_id
  confidential_dataset_id          = local.confidential_dataset_id
  cmek_keyring_name                = "cmek_keyring_${random_id.suffix.hex}"
  delete_contents_on_destroy       = var.delete_contents_on_destroy
  perimeter_additional_members     = var.perimeter_additional_members

  depends_on = [
    module.base_projects,
    module.iam_projects
  ]
}

resource "null_resource" "download_sample_cc_into_gcs" {
  provisioner "local-exec" {
    command = <<EOF
    curl https://eforexcel.com/wp/wp-content/uploads/2017/07/100-CC-Records.zip > cc_records.zip
    unzip cc_records.zip
    echo "Changing sample file encoding from ISO-8859-1 to UTF-8"
    iconv -f="ISO-8859-1" -t="UTF-8" 100\ CC\ Records.csv > ${local.cc_file_name}
    gsutil cp ${local.cc_file_name} gs://${module.secured_data_warehouse.landing_zone_bucket_name}
    rm ${local.cc_file_name} 100\ CC\ Records.csv cc_records.zip
EOF

  }

  depends_on = [
    module.secured_data_warehouse
  ]
}

module "de_identification_template" {
  source = "../..//modules/de-identification-template"

  project_id                = module.base_projects.data_governance_project_id
  terraform_service_account = var.terraform_service_account
  crypto_key                = module.kek.keys[local.kek_key_name]
  wrapped_key               = google_kms_secret_ciphertext.wrapped_key.ciphertext
  dlp_location              = local.location
  template_id_prefix        = "de_identification"
  template_file             = "${path.module}/templates/deidentification.tmpl"
  dataflow_service_account  = module.secured_data_warehouse.dataflow_controller_service_account_email
}

module "re_identification_template" {
  source = "../..//modules/de-identification-template"

  project_id                = module.base_projects.data_governance_project_id
  terraform_service_account = var.terraform_service_account
  crypto_key                = module.kek.keys[local.kek_key_name]
  wrapped_key               = google_kms_secret_ciphertext.wrapped_key.ciphertext
  dlp_location              = local.location
  template_id_prefix        = "re_identification"
  template_file             = "${path.module}/templates/reidentification.tmpl"
  dataflow_service_account  = module.secured_data_warehouse.confidential_dataflow_controller_service_account_email
}

resource "google_artifact_registry_repository_iam_member" "docker_reader" {
  provider = google-beta

  project    = module.template_project.project_id
  location   = local.location
  repository = "flex-templates"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse.dataflow_controller_service_account_email}"
}

resource "google_artifact_registry_repository_iam_member" "confidential_docker_reader" {
  provider = google-beta

  project    = module.template_project.project_id
  location   = local.location
  repository = "flex-templates"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse.confidential_dataflow_controller_service_account_email}"
}

// TODO: Replace with job that reads from public Bigquery dataset
module "regional_deid" {
  source = "../../modules/dataflow-flex-job"

  project_id              = module.base_projects.landing_zone_project_id
  name                    = "regional-flex-java-gcs-dlp-bq"
  container_spec_gcs_path = module.template_project.java_de_identify_template_gs_path
  region                  = local.location
  service_account_email   = module.secured_data_warehouse.dataflow_controller_service_account_email
  subnetwork_self_link    = module.base_projects.landing_zone_subnets_self_link
  kms_key_name            = module.secured_data_warehouse.cmek_landing_zone_crypto_key
  temp_location           = "gs://${module.secured_data_warehouse.landing_zone_dataflow_bucket_name}/tmp/"
  staging_location        = "gs://${module.secured_data_warehouse.landing_zone_dataflow_bucket_name}/staging/"
  max_workers             = 1

  parameters = {
    inputFilePattern       = "gs://${module.secured_data_warehouse.landing_zone_bucket_name}/${local.cc_file_name}"
    bqProjectId            = module.base_projects.non_confidential_data_project_id
    datasetName            = local.non_confidential_dataset_id
    batchSize              = 1000
    dlpProjectId           = module.base_projects.data_governance_project_id
    dlpLocation            = local.location
    deidentifyTemplateName = module.de_identification_template.template_full_path
  }

  depends_on = [
    google_artifact_registry_repository_iam_member.docker_reader,
    null_resource.download_sample_cc_into_gcs
  ]
}

resource "time_sleep" "wait_de_identify_job_execution" {
  create_duration = "600s"

  depends_on = [
    module.regional_deid
  ]
}

module "regional_reid" {
  source = "../../modules/dataflow-flex-job"

  project_id              = module.base_projects.confidential_data_project_id
  name                    = "dataflow-flex-regional-dlp-reid-job"
  container_spec_gcs_path = module.template_project.java_re_identify_template_gs_path
  region                  = local.location
  service_account_email   = module.secured_data_warehouse.confidential_dataflow_controller_service_account_email
  subnetwork_self_link    = module.base_projects.confidential_subnets_self_link
  kms_key_name            = module.secured_data_warehouse.cmek_reidentification_crypto_key
  temp_location           = "gs://${module.secured_data_warehouse.confidential_data_dataflow_bucket_name}/tmp/"
  staging_location        = "gs://${module.secured_data_warehouse.confidential_data_dataflow_bucket_name}/staging/"

  parameters = {
    inputBigQueryTable        = "${module.base_projects.non_confidential_data_project_id}:${local.non_confidential_dataset_id}.${trimsuffix(local.cc_file_name, ".csv")}"
    outputBigQueryDataset     = local.confidential_dataset_id
    deidentifyTemplateName    = module.re_identification_template.template_full_path
    dlpLocation               = local.location
    dlpProjectId              = module.base_projects.data_governance_project_id
    confidentialDataProjectId = module.base_projects.confidential_data_project_id
  }

  depends_on = [
    time_sleep.wait_de_identify_job_execution,
    google_bigquery_table.re_id
  ]
}
