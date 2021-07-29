
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

resource "google_compute_firewall" "allow_ingress_dataflow_workers" {
  name      = "fw-e-shared-private-0-i-a-dataflow-tcp-12345-12346"
  network   = module.vpc_service_controls.network_self_link
  project   = var.project_id
  direction = "INGRESS"
  priority  = 0

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  source_ranges = [var.subnet_ip]

  allow {
    protocol = "tcp"
    ports    = ["12345", "12346"]
  }
}

resource "google_compute_firewall" "allow_egress_dataflow_workers" {
  name      = "fw-e-shared-private-0-e-a-dataflow-tcp-12345-12346"
  network   = module.vpc_service_controls.network_self_link
  project   = var.project_id
  direction = "EGRESS"
  priority  = 0

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  destination_ranges = [var.subnet_ip]
  allow {
    protocol = "tcp"
    ports    = ["12345", "12346"]
  }
}
