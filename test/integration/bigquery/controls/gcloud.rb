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

names                     = attribute('emails')
project_id                = attribute('project_id')
high_policy_taxonomy_id   = attribute('high_policy_taxonomy_id')
medium_policy_taxonomy_id = attribute('medium_policy_taxonomy_id')
taxonomy_name             = attribute('taxonomy_name')

control 'gcloud' do
  title 'Gcloud Resources'

  describe command("gcloud data-catalog taxonomies policy-tags get-iam-policy #{high_policy_taxonomy_id} --taxonomy='#{taxonomy_name}' --location='us-east1' --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Verifies SA #{names}" do
      it 'should exist' do
        expect(data).to_not be_empty
      end
    end
  end
end
