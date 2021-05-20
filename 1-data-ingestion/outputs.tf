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

output "dataflow_controller_service_account_email" {
  description = "The service account email."
  value       = module.dataflow_controller_service_account.email
}

output "storage_writer_service_account_email" {
  description = "The service account email."
  value       = module.storage_writer_service_account.email
}

output "pubsub_writer_service_account_email" {
  description = "The service account email."
  value       = module.pubsub_writer_service_account.email
}
