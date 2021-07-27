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

resource "random_id" "suffix" {
  byte_length = 8
}

module "service_accounts" {
  source       = "terraform-google-modules/service-accounts/google"
  version      = ">=4.0.0"
  project_id   = var.bigquery_project_id
  names        = ["terraform-private-sa", "terraform-confidential-sa"]
  display_name = "Terraform SA accounts"
  description  = "Service accounts for BigQuery Sensitive Data"

  project_roles = [
    "${var.bigquery_project_id}=>roles/bigquery.dataViewer",
    "${var.bigquery_project_id}=>roles/datacatalog.viewer",
  ]
}

module "bigquery_sensitive_data" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 5.1.0"

  dataset_id                 = var.dataset_id
  description                = "Dataset for BigQuery Sensitive Data"
  project_id                 = var.bigquery_project_id
  location                   = var.location
  delete_contents_on_destroy = var.delete_contents_on_destroy

  tables = [
    {
      table_id = "sample_data",
      schema = templatefile("${path.module}/schema.template",
        {
          pt_ssn  = google_data_catalog_policy_tag.ssn_child_policy_tag.id,
          pt_name = google_data_catalog_policy_tag.name_child_policy_tag.id,
      }),
      time_partitioning  = null,
      range_partitioning = null,
      expiration_time    = null,
      clustering         = null,
      labels             = null,
    }
  ]

  dataset_labels = var.dataset_labels
}

resource "google_data_catalog_taxonomy" "secure_taxonomy" {
  provider               = google-beta
  project                = var.taxonomy_project_id
  region                 = var.location
  display_name           = "${var.taxonomy_name}-${random_id.suffix.hex}"
  description            = "Taxonomy created for BigQuery Sensitive Data"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
}

resource "google_data_catalog_policy_tag" "medium_parent_policy_tag" {
  provider     = google-beta
  taxonomy     = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name = "Medium security policy"
  description  = "A policy tag normally associated with medium security items"
}

resource "google_data_catalog_policy_tag" "name_child_policy_tag" {
  provider          = google-beta
  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = "PERSON_NAME"
  description       = "A full person name, which can include first names, middle names or initials, and last names."
  parent_policy_tag = google_data_catalog_policy_tag.medium_parent_policy_tag.id
}

resource "google_data_catalog_policy_tag" "high_parent_policy_tag" {
  provider     = google-beta
  taxonomy     = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name = "High security policy"
  description  = "A policy tag category used for high security access"
}

resource "google_data_catalog_policy_tag" "ssn_child_policy_tag" {
  provider          = google-beta
  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = "US_SOCIAL_SECURITY_NUMBER"
  description       = "A United States Social Security number (SSN) is a 9-digit number issued to US citizens, permanent residents, and temporary residents."
  parent_policy_tag = google_data_catalog_policy_tag.high_parent_policy_tag.id
}

resource "google_data_catalog_policy_tag_iam_member" "private_sa_name" {
  provider   = google-beta
  policy_tag = google_data_catalog_policy_tag.name_child_policy_tag.name
  role       = "roles/datacatalog.categoryFineGrainedReader"
  member     = "serviceAccount:${module.service_accounts.emails["terraform-private-sa"]}"

  depends_on = [
    module.service_accounts,
  ]
}

resource "google_data_catalog_policy_tag_iam_member" "confidential_sa_name" {
  provider   = google-beta
  policy_tag = google_data_catalog_policy_tag.name_child_policy_tag.name
  role       = "roles/datacatalog.categoryFineGrainedReader"
  member     = "serviceAccount:${module.service_accounts.emails["terraform-confidential-sa"]}"

  depends_on = [
    module.service_accounts,
  ]
}

resource "google_data_catalog_policy_tag_iam_member" "confidential_sa_ssn" {
  provider   = google-beta
  policy_tag = google_data_catalog_policy_tag.ssn_child_policy_tag.name
  role       = "roles/datacatalog.categoryFineGrainedReader"
  member     = "serviceAccount:${module.service_accounts.emails["terraform-confidential-sa"]}"

  depends_on = [
    module.service_accounts,
  ]
}
