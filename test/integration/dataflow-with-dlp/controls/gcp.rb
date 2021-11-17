# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

project_id = attribute('project_id')
bucket_data_ingestion_name = attribute('bucket_data_ingestion_name')

control 'gcp' do
  title 'GCP Resources'

  describe google_storage_bucket(name: bucket_data_ingestion_name) do
    it { should exist }
  end

  describe google_compute_firewall(
    project: project_id,
    name: 'fw-e-shared-private-0-i-a-dataflow-tcp-12345-12346'
  ) do
    its('direction') { should cmp 'INGRESS' }
    its('source_ranges') { should eq ['10.0.32.0/21'] }
    it { should allow_port_protocol('12345', 'tcp') }
    it { should allow_port_protocol('12346', 'tcp') }
  end

  describe google_compute_firewall(
    project: project_id,
    name: 'fw-e-shared-private-0-e-a-dataflow-tcp-12345-12346'
  ) do
    its('direction') { should cmp 'EGRESS' }
    its('destination_ranges') { should eq ['10.0.32.0/21'] }
    it { should allow_port_protocol('12345', 'tcp') }
    it { should allow_port_protocol('12346', 'tcp') }
  end
end
