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

resource "random_id" "random_suffix" {
  byte_length = 4
}

locals {
  region   = "us-central1"
  location = "us-central1-a"
}

//storage ingest bucket
module "dataflow-bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.1"

  project_id    = var.project_id
  name          = "bkt-${random_id.random_suffix.hex}-tmp-dataflow"
  location      = "US"
  force_destroy = true

  labels = {
    "enterprise_data_ingest_bucket" = "true"
  }
}

resource "null_resource" "download_sample_cc_into_gcs" {
  provisioner "local-exec" {
    command = <<EOF
    curl http://eforexcel.com/wp/wp-content/uploads/2017/07/1500000%20CC%20Records.zip > cc_records.zip
    unzip cc_records.zip
    rm cc_records.zip
    mv 1500000\ CC\ Records.csv cc_records.csv
    echo "Changing sample file encoding from ISO-8859-1 to UTF-8"
    iconv -f="ISO-8859-1" -t="UTF-8" cc_records.csv > temp_cc_records.csv
    mv temp_cc_records.csv cc_records.csv
    gsutil cp cc_records.csv gs://${module.dataflow-bucket.bucket.name}
    rm cc_records.csv
EOF

  }
}


module "de_identification_template" {
  source = "../..//modules/de_identification_template"

  project_id                = var.project_id
  terraform_service_account = var.terraform_service_account
  crypto_key                = var.crypto_key
  wrapped_key               = var.wrapped_key
  dlp_location              = "global"
  template_file             = "${path.module}/deidentification.tmpl"
  dataflow_service_account  = var.dataflow_service_account
}

resource "google_app_engine_application" "app" {
  project     = var.project_id
  location_id = "us-central"
}

resource "google_cloud_scheduler_job" "scheduler" {
  name     = "scheduler-demo"
  schedule = "0 0 * * *"
  # This needs to be us-central1 even if App Engine is in us-central.
  # You will get a resource not found error if just using us-central.
  region  = "us-central1"
  project = var.project_id

  http_target {
    http_method = "POST"
    headers = {
      "Accept"       = "application/json"
      "Content-Type" = "application/json"
    }
    uri = "https://dataflow.googleapis.com/v1b3/projects/${var.project_id}/locations/${local.region}/templates"
    oauth_token {
      service_account_email = var.terraform_service_account
    }

    # need to encode the string
    body = base64encode(<<-EOT
    {
      "jobName": "batch-dataflow-flow",
      "environment": {
        "maxWorkers": 5,
        "tempLocation": "gs://${module.dataflow-bucket.bucket.name}",
        "zone": "${local.location}",
        "ipConfiguration": "WORKER_IP_PRIVATE",
        "enableStreamingEngine": true,
        "network": "${var.network_self_link}",
        "serviceAccountEmail": "${var.dataflow_service_account}",
        "subnetwork": "${var.subnetwork_self_link}"
      },
      "parameters" : {
        "inputFilePattern"       : "gs://${module.dataflow-bucket.bucket.name}/cc_records.csv",
        "datasetName"            : "${var.dataset_id}",
        "batchSize"              : "1000",
        "dlpProjectId"           : "${var.project_id}",
        "deidentifyTemplateName" : "projects/${var.project_id}/locations/global/deidentifyTemplates/${module.de_identification_template.template_id}",
      },
      "gcsPath": "gs://dataflow-templates/latest/GCS_Text_to_BigQuery"
    }
EOT
    )
  }
  depends_on = [
    google_app_engine_application.app
  ]
}