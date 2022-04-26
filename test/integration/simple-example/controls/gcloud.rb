# Copyright 2021-2022 Google LLC
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
blueprint_type = attribute('blueprint_type')
blueprint_type_semversion = blueprint_type.split('/')[-1]
blueprint_type_base = blueprint_type.split('/').slice(0, 3).join('/')
SEMVERSION_REGEX = /^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$/

boolean_policy_constraints = [
  'constraints/iam.disableServiceAccountCreation',
  'constraints/iam.disableServiceAccountKeyCreation',
  'constraints/compute.requireOsLogin',
  'constraints/compute.disableSerialPortLogging'
]

list_policy_constraints = [
  'constraints/compute.restrictProtocolForwardingCreationForTypes',
  # 'constraints/compute.restrictSharedVpcSubnetworks',
  'constraints/gcp.resourceLocations'
]

control 'gcloud' do
  title 'boolean and list organization policy and output tests'

  boolean_policy_constraints.each do |constraint|
    describe command("gcloud beta resource-manager org-policies list --project=#{project_id} --format=json") do
      its(:exit_status) { should eq 0 }
      its(:stderr) { should eq '' }

      let(:data) do
        if subject.exit_status.zero?
          JSON.parse(subject.stdout).select { |x| x['constraint'] == constraint }[0]
        else
          {}
        end
      end

      describe "boolean org policy #{constraint}" do
        it 'should exist' do
          expect(data).to_not be_empty
        end
      end

      describe "boolean org policy #{constraint}" do
        it 'should be enforced' do
          expect(data['booleanPolicy']['enforced']).to eq true
        end
      end
    end
  end

  list_policy_constraints.each do |constraint|
    describe command("gcloud beta resource-manager org-policies list --project=#{project_id} --format=json") do
      its(:exit_status) { should eq 0 }
      its(:stderr) { should eq '' }

      let(:data) do
        if subject.exit_status.zero?
          JSON.parse(subject.stdout).select { |x| x['constraint'] == constraint }[0]
        else
          {}
        end
      end

      describe "list org policy #{constraint}" do
        it 'should exist' do
          expect(data).to_not be_empty
        end
      end

      describe "list org policy #{constraint}" do
        it 'should have allowedValues' do
          expect(data['listPolicy']['allowedValues']).to_not be_empty
        end
      end
    end
  end

  describe "check blueprint_type #{blueprint_type}" do
    it 'should have a valid base attribution' do
      expect("#{blueprint_type_base}" ).to eq 'blueprints/terraform/terraform-google-secured-data-warehouse'
    end
  end

  describe "check blueprint_type #{blueprint_type}" do
    it 'should have a valid semversion' do
      expect("#{blueprint_type_semversion}" ).to match SEMVERSION_REGEX
    end
  end
end
