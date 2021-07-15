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
# limitations under the License

project_id = attribute('project_id')

boolean_policy_constraints = [
  'constraints.gcp.resourceLocations',
  'constraints/iam.disableServiceAccountCreation',
  'constraints/compute.requireOsLogin',
  'constraints/compute.restrictProtocolForwardingCreationForTypes',
  'constraints/compute.restrictSharedVpcSubnetworks',
  'constraints/compute.disableSerialPortLogging',
]

control 'gcloud' do
  title 'folder organization policy tests'

  boolean_policy_constraints.each do |constraint|
  describe command("gcloud resource-manager org-policies list --project=#{project_id} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout).select { |x| x['constraint'] == constraint }[0]
      else
        {}
      end
    end

    describe "boolean folder org policy #{constraint}" do
      it 'should exist' do
        expect(data).to_not be_empty
      end
    end
  end
end
