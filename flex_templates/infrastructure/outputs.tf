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


output "flex_template_bucket_name" {
  description = "The name of the bucket created to store the flex template."
  value       = google_storage_bucket.templates_bucket.name
}

output "flex_template_repository_name" {
  description = "The name of the flex template artifact registry repository."
  value       = google_artifact_registry_repository.flex_templates.name
}

output "flex_template_repository_url" {
  description = "URL of the flex template artifact registry repository."
  value       = local.repository_url
}
