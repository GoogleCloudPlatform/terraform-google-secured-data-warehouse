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

data_governance_project_id = attribute('data_governance_project_id')
taxonomy_name              = "secured_taxonomy"

control 'gcloud' do
  title 'Gcloud Resources'

  describe command("gcloud data-catalog taxonomies list --location='us-east4' --project=#{data_governance_project_id}  --filter=displayName=#{taxonomy_name} --format=json") do
    its(:exit_status) { should eq 0 }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Taxonomy #{taxonomy_name}" do
      it 'should exist' do
        expect(data[0]).to_not be_empty
      end
    end
  end
end
