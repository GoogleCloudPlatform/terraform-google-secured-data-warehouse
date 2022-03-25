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

output "sinks" {
  description = "The list of sinks that were created."
  value = toset([
    for value in module.log_export : value
  ])
}

output "bucket_name" {
  description = "The name of the bucket that will store the exported logs."
  value       = local.bucket_name
}

output "sink_projects" {
  description = "The list of the projects that the sink was created."
  value       = local.parent_resource_ids
}
