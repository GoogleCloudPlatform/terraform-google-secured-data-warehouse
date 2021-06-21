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
data_governance_keyring = attribute('data_governance_keyring')
data_governance_location = attribute('data_governance_location')
data_governance_key = attribute('data_governance_key')
data_governance_template_id = attribute('data_governance_template_id')
template_display_name = attribute('template_display_name')
template_description = attribute('template_description')

control 'gcloud' do
  title 'Gcloud Resources'

  describe command("curl -s -X GET -H \"Authorization: Bearer \" $(gcloud auth application-default print-access-token) https://dlp.googleapis.com/v2/projects/#{project_id}/locations/#{data_governance_location}/deidentifyTemplates/#{data_governance_template_id}") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "de-identification Template #{data_governance_template_id}" do

      it 'should exist' do
        expect(data).to_not be_empty
      end

      it { expect(data).to include('name' => "projects/#{project_id}/locations/#{data_governance_location}/deidentifyTemplates/#{data_governance_template_id}") }
      it { expect(data).to include('display_name' => "#{template_display_name}") }
      it { expect(data).to include('description' => "#{template_description}") }

      it { expect(data["deidentifyConfig"]["recordTransformations"]["fieldTransformations"]).to include(
        including(
          "primitiveTransformation" => including(
            "cryptoReplaceFfxFpeConfig" => including(
              "cryptoKey" => including(
                "kmsWrapped" => including(
                  "cryptoKeyName" => "#{data_governance_key}"
                )
              )
            )
          )
        )
      )
    }
    end

  end
end
