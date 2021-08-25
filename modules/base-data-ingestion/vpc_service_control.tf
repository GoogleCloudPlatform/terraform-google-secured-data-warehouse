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
  perimeter_members = distinct(concat([
    "serviceAccount:${module.dataflow_controller_service_account.email}",
    "serviceAccount:${google_service_account.storage_service_account.email}",
    "serviceAccount:${google_service_account.pubsub_writer_service_account.email}"
  ], var.perimeter_members))
}

// vpc service controls network infrastructure
module "dwh_networking" {
  source = "../..//modules/dwh-networking"

  org_id                           = var.org_id
  project_id                       = var.project_id
  region                           = var.region
  vpc_name                         = var.vpc_name
  access_context_manager_policy_id = var.access_context_manager_policy_id
  subnet_ip                        = var.subnet_ip
  perimeter_members                = local.perimeter_members
  commom_suffix                    = random_id.suffix.hex

  restricted_services = [
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "dataflow.googleapis.com",
    "pubsub.googleapis.com"
  ]

  # depends_on needed to prevent intermittent errors
  # when the VPC-SC is created but perimeter member
  # not yet propagated.
  depends_on = [
    module.data_ingest_bucket,
    module.bigquery_dataset,
    module.data_ingest_topic
  ]
}
