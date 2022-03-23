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

output "job_id" {
  description = "The unique ID of this job."
  value       = google_dataflow_flex_template_job.dataflow_flex_template_job.job_id

}

output "state" {
  description = "The current state of the resource, selected from the JobState enum. See https://cloud.google.com/dataflow/docs/reference/rest/v1b3/projects.jobs#Job.JobState ."
  value       = google_dataflow_flex_template_job.dataflow_flex_template_job.state
}
