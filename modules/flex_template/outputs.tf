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

output "flex_template_image_tag" {
  value       = local.flex_template_image_tag
  description = "The Flex Template image TAG created."
}

output "flex_template_gs_path" {
  value       = local.template_gs_path
  description = "Google Cloud Storage path to the flex template."
}

output "cloud_build_logs_bucket_name" {
  value       = module.cloud-build-logs.bucket.name
  description = "The name of the bucket created to store the Cloud Build logs."
}

output "templates_bucket_name" {
  value       = module.templates.bucket.name
  description = "The name of the bucket created to store the flex template."
}