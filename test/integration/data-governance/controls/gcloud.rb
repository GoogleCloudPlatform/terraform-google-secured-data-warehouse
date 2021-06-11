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

control 'gcloud' do
  title 'Gcloud Resources'

  describe command("curl -s -X GET -H \"Authorization: Bearer \"`gcloud auth print-access-token` https://dlp.googleapis.com/v2/projects/#{project_id}/deidentifyTemplates/#{data_governance_template_id}") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    it { expect(data).to include(name: "projects/#{project_id}/deidentifyTemplates/#{data_governance_template_id}") }

  end
end
