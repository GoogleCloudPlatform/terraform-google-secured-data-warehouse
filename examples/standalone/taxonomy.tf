/**
 * Copyright 2022 Google LLC
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
  confidential_tags = {
    ein = {
      display_name = "US_EMPLOYER_IDENTIFICATION_NUMBER"
      description  = "The employer identification number."
    }
  }

  private_tags = {
    name = {
      display_name = "PERSON_NAME"
      description  = "A full person name, which can include first names, middle names or initials, and last names."
    }
    street = {
      display_name = "STREET_ADDRESS"
      description  = "Street Address."
    }
    state = {
      display_name = "US_STATE"
      description  = "Name of the state."
    }
  }

  sensitive_tags = {
    income_amt = {
      display_name = "INCOME_AMT"
      description  = "Income amount."
    }
    revenue_amt = {
      display_name = "REVENUE_AMT"
      description  = "Revenue amount."
    }
  }
}

resource "google_data_catalog_taxonomy" "secure_taxonomy" {
  provider = google-beta

  project                = module.base_projects.data_governance_project_id
  region                 = local.location
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
  description  = "Most sensitive data classification. Significant damage to enterprise."
}

resource "google_data_catalog_policy_tag" "confidential_tags" {
  provider = google-beta

  for_each = local.confidential_tags

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = each.value["display_name"]
  description       = each.value["description"]
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_confidential.id
}

resource "google_data_catalog_policy_tag" "policy_tag_private" {
  provider = google-beta

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = "2_Private"
  description       = "Data meant to be private. Likely to cause damage to enterprise."
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_confidential.id
}

resource "google_data_catalog_policy_tag" "private_tags" {
  provider = google-beta

  for_each = local.private_tags

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = each.value["display_name"]
  description       = each.value["description"]
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_private.id
}

resource "google_data_catalog_policy_tag" "policy_tag_sensitive" {
  provider = google-beta

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = "1_Sensitive"
  description       = "Data not meant to be public."
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_private.id
}

resource "google_data_catalog_policy_tag" "sensitive_tags" {
  provider = google-beta

  for_each = local.sensitive_tags

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = each.value["display_name"]
  description       = each.value["description"]
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_sensitive.id
}

resource "google_bigquery_table" "re_id" {
  dataset_id          = local.confidential_dataset_id
  project             = module.base_projects.confidential_data_project_id
  table_id            = local.confidential_table_id
  friendly_name       = local.confidential_table_id
  deletion_protection = !var.delete_contents_on_destroy

  schema = templatefile("${path.module}/templates/schema.template",
    {
      pt_ein     = google_data_catalog_policy_tag.confidential_tags["ein"].id,
      pt_name    = google_data_catalog_policy_tag.private_tags["name"].id,
      pt_street  = google_data_catalog_policy_tag.private_tags["street"].id,
      pt_state   = google_data_catalog_policy_tag.private_tags["state"].id,
      pt_income  = google_data_catalog_policy_tag.sensitive_tags["income_amt"].id,
      pt_revenue = google_data_catalog_policy_tag.sensitive_tags["revenue_amt"].id
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
  project = module.base_projects.confidential_data_project_id
}

resource "google_data_catalog_taxonomy_iam_binding" "confidential_bq_binding" {
  provider = google-beta

  project  = module.base_projects.data_governance_project_id
  taxonomy = google_data_catalog_taxonomy.secure_taxonomy.name
  role     = "roles/datacatalog.categoryFineGrainedReader"
  members = [
    "serviceAccount:${data.google_bigquery_default_service_account.bq_sa.email}",
    "serviceAccount:${module.secured_data_warehouse.confidential_dataflow_controller_service_account_email}"
  ]
}
