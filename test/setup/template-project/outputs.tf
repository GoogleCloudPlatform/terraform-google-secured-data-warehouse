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

output "project_id" {
  value = module.external_flex_template_project.project_id
}

output "python_de_identify_template_gs_path" {
  value = local.python_de_identify_template_gs_path

  depends_on = [
    null_resource.python_de_identification_flex_template
  ]
}

output "python_re_identify_template_gs_path" {
  value = local.python_re_identify_template_gs_path

  depends_on = [
    null_resource.python_re_identification_flex_template
  ]
}

output "sdx_project_number" {
  description = "The Project Number to configure Secure data exchange with egress rule for the dataflow templates."
  value       = module.external_flex_template_project.project_number
}
