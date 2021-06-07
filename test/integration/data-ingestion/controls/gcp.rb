# Copyright 2018 Google LLC
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

dataflow_controller_service_account_email = attribute('dataflow_controller_service_account_email')
storage_writer_service_account_email = attribute('storage_writer_service_account_email')
pubsub_writer_service_account_email = attribute('pubsub_writer_service_account_email')
data_ingest_bucket_names = attribute('data_ingest_bucket_names')
data_ingest_topic_name = attribute('data_ingest_topic_name')
network_name = attribute('network_name')
project_id = attribute('project_id')
network_self_link = attribute('network_self_link')
subnets_names = attribute('subnets_names')
subnets_ips = attribute('subnets_ips')
subnets_self_links = attribute('subnets_self_links')
subnets_regions = attribute('subnets_regions')
access_level_name = attribute('access_level_name')
service_perimeter_name = attribute('service_perimeter_name')

control 'gcp' do
  title 'GCP Resources'

  data_ingest_bucket_names.each do |bucket_name|
    describe google_storage_bucket(name: bucket_name) do
      it { should exist }
    end
  end

  describe google_compute_network(name: network_name, project: project_id) do
    it { should exist }
  end

  describe google_pubsub_topic(project: project_id, name: data_ingest_topic_name) do
    it { should exist }
  end

  describe google_service_account(project: project_id, name: dataflow_controller_service_account_email) do
    it { should exist }
  end

  describe google_service_account(project: project_id, name: storage_writer_service_account_email) do
    it { should exist }
  end

  describe google_service_account(project: project_id, name: pubsub_writer_service_account_email) do
    it { should exist }
  end
end
