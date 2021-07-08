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

project_id                        = attribute('project_id')
social_security_number_policy_tag = attribute('social_security_number_policy_tag')
person_name_policy_tag            = attribute('person_name_policy_tag')
taxonomy_name                     = attribute('taxonomy_name')
member_policy_ssn_confidential    = attribute('member_policy_ssn_confidential')
member_policy_name_confidential   = attribute('member_policy_name_confidential')
member_policy_name_private        = attribute('member_policy_name_private')

control 'gcloud' do
  title 'Gcloud Resources'

  describe command("gcloud data-catalog taxonomies policy-tags get-iam-policy #{social_security_number_policy_tag} --taxonomy='#{taxonomy_name}' --location='us-east1' --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Verifies SA social_security_number_policy_tag #{member_policy_ssn_confidential}" do
      it 'should exist' do
        expect(data).to_not be_empty
      end

    it "#{member_policy_ssn_confidential} Confidential SA should have the right role on high policy tag" do
      expect(data['bindings'][0]['members']).to include(member_policy_ssn_confidential)
      expect(data['bindings'][0]['role']).to eq "roles/datacatalog.categoryFineGrainedReader"
    end
    end
  end

  describe command("gcloud data-catalog taxonomies policy-tags get-iam-policy #{person_name_policy_tag} --taxonomy='#{taxonomy_name}' --location='us-east1' --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Verifies SA person_name_policy_tag #{member_policy_name_private}" do
      it 'should exist' do
        expect(data).to_not be_empty
      end

    it "#{member_policy_name_private} Confidential SA should have the right role on medium policy" do
      expect(data['bindings'][0]['members']).to include(member_policy_name_private)
      expect(data['bindings'][0]['role']).to eq "roles/datacatalog.categoryFineGrainedReader"
    end
    end
  end

  describe command("gcloud data-catalog taxonomies policy-tags get-iam-policy #{person_name_policy_tag} --taxonomy='#{taxonomy_name}' --location='us-east1' --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Verifies SA social_security_number_policy_tag #{member_policy_name_confidential}" do
      it 'should exist' do
        expect(data).to_not be_empty
      end

    it "#{member_policy_name_private} Confidential SA should have the right role on medium policy" do
      expect(data['bindings'][0]['members']).to include(member_policy_name_confidential)
      expect(data['bindings'][0]['role']).to eq "roles/datacatalog.categoryFineGrainedReader"
    end
    end
  end

  describe command("gcloud data-catalog taxonomies list --location='us-east1' --project=#{project_id} --format=json") do
    its(:exit_status) { should eq 0 }
  end

=begin
# The test below depends of the fix from the bug https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/35

  describe command("bq show --schema  --headless --location='us-east1' --project_id=#{project_id} dtwh_dataset.sample_data") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }
    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end
    it { expect(data).to include(
      including(
        'name' => 'social_security_number', 'policyTags' => including('names' => including("#{social_security_number_policy_tag}")))
      )
    }
    it { expect(data).to include(
      including(
        'name' => 'name', 'policyTags' => including('names' => including("#{person_name_policy_tag}")))
      )
    }
  end

=end
end
