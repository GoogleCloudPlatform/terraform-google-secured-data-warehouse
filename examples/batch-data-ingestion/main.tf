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
  httpRequestTemplate = templatefile(
    "${path.module}/httpRequest.tmpl",
    {
      location                            = local.location,
      network_self_link                   = var.network_self_link,
      dataflow_service_account            = var.dataflow_service_account,
      subnetwork_self_link                = var.subnetwork_self_link,
      inputFilePattern                    = "gs://${module.dataflow-bucket.bucket.name}/cc_records.csv",
      project_id                          = var.project_id,
      dataset_id                          = var.dataset_id,
      table_name                          = var.table_name,
      javascriptTextTransformFunctionName = "transform",
      JSONPath                            = "gs://${module.dataflow-bucket.bucket.name}/code/schema.json",
      javascriptTextTransformGcsPath      = "gs://${module.dataflow-bucket.bucket.name}/code/transform.js",
      bigQueryLoadingTemporaryDirectory   = "gs://${module.dataflow-bucket.bucket.name}/tmp"
    }
  )
}

//storage ingest bucket
module "dataflow-bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.1"

  project_id    = var.project_id
  name          = "bkt-${random_id.random_suffix.hex}-tmp-dataflow"
  location      = "US"
  force_destroy = var.bucket_force_destroy
  encryption    = { "default_kms_key_name" = var.crypto_key }

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

resource "google_storage_bucket_object" "schema" {
  name   = "code/schema.json"
  source = "${path.module}/schema.json"
  bucket = module.dataflow-bucket.bucket.name
  depends_on = [
    module.dataflow-bucket
  ]
}

resource "google_storage_bucket_object" "transform_code" {
  name   = "code/transform.js"
  source = "${path.module}/transform.js"
  bucket = module.dataflow-bucket.bucket.name
  depends_on = [
    module.dataflow-bucket
  ]
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
    body = base64encode(local.httpRequestTemplate)
  }
  depends_on = [
    google_app_engine_application.app,
    google_storage_bucket_object.schema,
    google_storage_bucket_object.transform_code
  ]
}
