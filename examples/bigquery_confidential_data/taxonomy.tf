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

resource "google_data_catalog_taxonomy" "secure_taxonomy" {
  provider = google-beta

  project                = var.data_governance_project_id
  region                 = local.region
  display_name           = local.taxonomy_display_name
  description            = "Taxonomy created for Sample Sensitive Data"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]

  depends_on = [
    module.secured_data_warehouse
  ]
}

resource "google_data_catalog_policy_tag" "policy_tag_confidential" {
  provider = google-beta

  taxonomy     = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name = "3_Confidential"
  description  = "Most sensitive data classification. Significant damage to enterprise"
}

resource "google_data_catalog_policy_tag" "child_policy_tag_card_number" {
  provider = google-beta

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = "CREDIT_CARD_NUMBER"
  description       = "A credit card number is 12 to 19 digits long. They are used for payment transactions globally."
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_confidential.id
}

resource "google_data_catalog_policy_tag" "child_policy_tag_cvv" {
  provider = google-beta

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = "CARD_VERIFICATION_VALUE"
  description       = "A card verification value is 3 to 4 digits long. Used for card not present transactions."
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_confidential.id
}

resource "google_data_catalog_policy_tag" "policy_tag_private" {
  provider = google-beta

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = "2_Private"
  description       = "Data meant to be private. Likely to cause damage to enterprise"
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_confidential.id
}

resource "google_data_catalog_policy_tag" "child_policy_tag_card_holder_name" {
  provider = google-beta

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = "PERSON_NAME"
  description       = "A full person name, which can include first names, middle names or initials, and last names."
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_private.id
}

resource "google_data_catalog_policy_tag" "child_policy_tag_card_pin" {
  provider = google-beta

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = "CREDIT_CARD_PIN"
  description       = "Card personal identification number."
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_private.id
}

resource "google_data_catalog_policy_tag" "child_policy_tag_card_expiry_date" {
  provider = google-beta

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = "CARD_EXPIRY_DATE"
  description       = "Card expiry date."
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_private.id
}

resource "google_data_catalog_policy_tag" "policy_tag_sensitive" {
  provider = google-beta

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = "1_Sensitive"
  description       = "Data not meant to be public."
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_private.id
}

resource "google_data_catalog_policy_tag" "child_policy_tag_credit_limit" {
  provider = google-beta

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = "CREDIT_LIMIT"
  description       = "Credit allowed to individual."
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_sensitive.id
}

resource "google_bigquery_table" "re_id" {
  dataset_id          = local.confidential_dataset_id
  project             = var.confidential_data_project_id
  table_id            = local.confidential_table_id
  friendly_name       = local.confidential_table_id
  deletion_protection = !var.delete_contents_on_destroy


  schema = templatefile("${path.module}/templates/schema.template",
    {
      pt_credit_limit = google_data_catalog_policy_tag.child_policy_tag_credit_limit.id,
      pt_name         = google_data_catalog_policy_tag.child_policy_tag_card_holder_name.id,
      pt_card_number  = google_data_catalog_policy_tag.child_policy_tag_card_number.id,
      pt_cvv          = google_data_catalog_policy_tag.child_policy_tag_cvv.id,
      pt_card_pin     = google_data_catalog_policy_tag.child_policy_tag_card_pin.id,
      pt_expiry_date  = google_data_catalog_policy_tag.child_policy_tag_card_expiry_date.id,
  })

  lifecycle {
    ignore_changes = [
      encryption_configuration # managed by the confidential dataset default_encryption_configuration.
    ]
  }

  depends_on = [
    module.secured_data_warehouse
  ]
}

data "google_bigquery_default_service_account" "bq_sa" {
  project = var.confidential_data_project_id
}

resource "google_data_catalog_taxonomy_iam_binding" "confidential_bq_binding" {
  provider = google-beta

  project  = var.data_governance_project_id
  taxonomy = google_data_catalog_taxonomy.secure_taxonomy.name
  role     = "roles/datacatalog.categoryFineGrainedReader"
  members = [
    "serviceAccount:${data.google_bigquery_default_service_account.bq_sa.email}",
    "serviceAccount:${module.secured_data_warehouse.confidential_dataflow_controller_service_account_email}"
  ]
}
