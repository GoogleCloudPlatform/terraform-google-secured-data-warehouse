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

project_number = attribute('project_number')
service_perimeter_name = attribute('service_perimeter_name')
access_level_name = attribute('access_level_name')
organization_policy_name = attribute('organization_policy_name')
terraform_service_account = attribute('terraform_service_account')
perimeter_additional_members = attribute('perimeter_additional_members')

dataflow_controller_service_account_email = attribute('dataflow_controller_service_account_email')
storage_writer_service_account_email = attribute('storage_writer_service_account_email')
pubsub_writer_service_account_email = attribute('pubsub_writer_service_account_email')

restricted_services = ['pubsub.googleapis.com', 'bigquery.googleapis.com', 'storage.googleapis.com', 'dataflow.googleapis.com']

members = [{
  'members' => [
    "serviceAccount:#{terraform_service_account}",
    "serviceAccount:#{dataflow_controller_service_account_email}",
    "serviceAccount:#{storage_writer_service_account_email}",
    "serviceAccount:#{pubsub_writer_service_account_email}"
  ].concat(perimeter_additional_members)
}]

resources = ["projects/#{project_number}"]

control 'gcloud' do
  title 'Gcloud Resources'

  describe command("gcloud access-context-manager levels describe #{access_level_name} --policy #{organization_policy_name} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Access Level name #{access_level_name}" do
      it 'should exist' do
        expect(data).to_not be_empty
      end

      it "should have name #{access_level_name}" do
        expect(data).to include(
          'name' => "accessPolicies/#{organization_policy_name}/accessLevels/#{access_level_name}"
        )
      end

      it "should have members #{members}" do
        expect(data['basic']).to include(
          'conditions' => members
        )
      end
    end
  end

  describe command("gcloud access-context-manager perimeters describe #{service_perimeter_name} --policy=#{organization_policy_name} --format json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Service perimiter name #{service_perimeter_name}" do
      it 'should exist' do
        expect(data).to_not be_empty
      end

      it "should have Access Levels #{access_level_name}" do
        expect(data['status']).to include(
          'accessLevels' => ["accessPolicies/#{organization_policy_name}/accessLevels/#{access_level_name}"]
        )
      end

      it "should have resources #{resources}" do
        expect(data['status']).to include(
          'resources' => resources
        )
      end

      it "should have restricted Services #{restricted_services}" do
        expect(data['status']).to include(
          'restrictedServices' => restricted_services
        )
      end
    end
  end
end
