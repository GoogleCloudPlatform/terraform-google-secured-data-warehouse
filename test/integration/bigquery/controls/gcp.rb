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

names         = attribute('emails')
project_id    = attribute('project_id')
dataset_id    = attribute('dataset_id')
taxonomy_name = attribute('taxonomy_name')

control 'gcp' do
  title 'GCP Resources'

  describe google_service_account(project: project_id, name: names['terraform-confidential-sa']) do
    it { should exist }
  end
  describe google_service_account(project: project_id, name: names['terraform-private-sa']) do
    it { should exist }
  end

  describe google_dataset_id(project: project_id, name: dataset_id) do
    it { should exist }
  end

  describe google_taxonomy_name(project: project_id, name: taxonomy_name) do
    it { should exist }
  end
end
