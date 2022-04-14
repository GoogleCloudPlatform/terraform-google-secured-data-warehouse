/**
 * Copyright 2021-2022 Google LLC
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
  java_pipeline_options = {
    serviceAccount        = var.service_account_email
    subnetwork            = var.subnetwork_self_link
    dataflowKmsKey        = var.kms_key_name
    tempLocation          = var.temp_location
    stagingLocation       = var.staging_location
    maxNumWorkers         = var.max_workers
    usePublicIps          = var.use_public_ips
    enableStreamingEngine = var.enable_streaming_engine
  }

  python_pipeline_options = {
    service_account_email   = var.service_account_email
    subnetwork              = var.subnetwork_self_link
    dataflow_kms_key        = var.kms_key_name
    temp_location           = var.temp_location
    staging_location        = var.staging_location
    max_num_workers         = var.max_workers
    no_use_public_ips       = !var.use_public_ips
    enable_streaming_engine = var.enable_streaming_engine
  }

  pipeline_options = var.job_language == "JAVA" ? local.java_pipeline_options : local.python_pipeline_options

  network_tags                       = join(";", var.network_tags)
  network_tags_experiment            = local.network_tags != "" ? "use_network_tags=${local.network_tags},use_network_tags_for_flex_templates=${local.network_tags}" : ""
  kms_on_streaming_engine_experiment = var.kms_key_name != null && var.enable_streaming_engine ? "enable_kms_on_streaming_engine" : ""
  experiment_options                 = local.network_tags_experiment != "" || local.kms_on_streaming_engine_experiment != "" ? join(",", compact([local.kms_on_streaming_engine_experiment, local.network_tags_experiment])) : ""
  experiments                        = local.experiment_options != "" || var.additional_experiments != "" ? { experiments = join(",", compact([local.experiment_options, var.additional_experiments])) } : {}
}

resource "google_dataflow_flex_template_job" "dataflow_flex_template_job" {
  provider = google-beta

  project                 = var.project_id
  name                    = var.name
  container_spec_gcs_path = var.container_spec_gcs_path
  region                  = var.region
  on_delete               = var.on_delete

  parameters = merge(var.parameters, local.pipeline_options, local.experiments)
}
