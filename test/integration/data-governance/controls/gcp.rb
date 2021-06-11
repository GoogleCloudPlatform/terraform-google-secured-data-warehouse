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

project_id = attribute('project_id')
terraform_service_account = attribute('terraform_service_account')
data_governance_keyring = attribute('data_governance_keyring')
data_governance_location = attribute('data_governance_location')
data_governance_key = attribute('data_governance_key')
data_governance_template_id = attribute('data_governance_template_id')

control 'gcp' do
  title 'GCP Resources'

  describe google_kms_key_ring(project: project_id, location: data_governance_location, name: data_governance_keyring) do
    it { should exist }
  end

  describe google_kms_crypto_key(project: project_id, location: data_governance_location, key_ring_name: data_governance_keyring, name: data_governance_key) do
    it { should exist }
  end

end