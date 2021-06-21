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

output "location" {
  description = "Location for storing your BigQuery data when you create a dataset."
  value       = var.location
}

output "project_id" {
  description = "Project where service accounts and core APIs will be enabled."
  value       = var.project_id
}

output "dataset_id" {
  description = "The dataset ID to deploy to data-warehouse"
  value       = var.dataset_id
}