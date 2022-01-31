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

// depends_on is necessary to ensure that the bigquery table is already created
output "bigquery_confidential_table" {
  description = "The data ingestion project Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account."
  value       = local.bigquery_confidential_table

  depends_on = [
    module.regional_deid_pipeline
  ]
}

// depends_on is necessary to ensure that the bigquery table is already created
output "bigquery_non_confidential_table" {
  description = "The data ingestion project Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account."
  value       = local.bigquery_non_confidential_table

  depends_on = [
    module.regional_reid_pipeline
  ]
}
