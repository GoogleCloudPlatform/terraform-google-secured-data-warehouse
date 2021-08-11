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
dataflow_controller_service_account_email = attribute('dataflow_controller_service_account_email')
templates_bucket_name = attribute('templates_bucket_name')


control 'gcloud' do
  title 'Gcloud Resources'

  describe command("gcloud beta artifacts repositories describe flex-templates --location=us-central1 --project=#{project_id} --format=json") do
    its(:exit_status) { should eq 0 }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Flex Template Repository" do

      it 'should exist' do
        expect(data).to_not be_empty
      end

      it { expect(data).to include('name' => "projects/#{project_id}/locations/us-central1/repositories/flex-templates") }
      it { expect(data).to include('format' => "DOCKER") }

    end
  end

  describe command("gcloud beta artifacts repositories get-iam-policy flex-templates --location=us-central1 --project=#{project_id} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Flex Template Repository IAM policy" do

      it 'should exist' do
        expect(data).to_not be_empty
      end

      it { expect(data["bindings"]).to include(
        including(
          "role" => "roles/artifactregistry.reader",
          "members" => including("serviceAccount:#{dataflow_controller_service_account_email}")
        )
      )}

    end
  end

  describe command("gcloud beta artifacts docker images describe us-central1-docker.pkg.dev/#{project_id}/flex-templates/regional_dlp_flex:0.1.0 --project=#{project_id} --format=json") do
    its(:exit_status) { should eq 0 }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Flex Template Docker image" do

      it 'should exist' do
        expect(data).to_not be_empty
      end

    end
  end

  describe command("gcloud beta artifacts repositories describe python-modules --location=us-central1 --project=#{project_id} --format=json") do
    its(:exit_status) { should eq 0 }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Python modules Repository" do

      it 'should exist' do
        expect(data).to_not be_empty
      end

      it { expect(data).to include('name' => "projects/#{project_id}/locations/us-central1/repositories/python-modules") }
      it { expect(data).to include('format' => "PYTHON") }

    end
  end

  describe command("gcloud beta artifacts repositories get-iam-policy python-modules --location=us-central1 --project=#{project_id} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Python modules Repository IAM policy" do

      it 'should exist' do
        expect(data).to_not be_empty
      end

      it { expect(data["bindings"]).to include(
        including(
          "role" => "roles/artifactregistry.reader",
          "members" => including("serviceAccount:#{dataflow_controller_service_account_email}")
        )
      )}

    end
  end

  describe command("gcloud artifacts packages list --repository=python-modules --location=us-central1 --project=#{project_id} --format=json") do
    its(:exit_status) { should eq 0 }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Python modules Repository packages" do

      it 'should exist' do
        expect(data).to_not be_empty
      end

      it { expect(data).to include(including("name" => "apache-beam")) }
      it { expect(data).to include(including("name" => "google-cloud-dlp")) }

    end
  end

  describe command("gsutil ls gs://#{templates_bucket_name}/dataflow/flex_templates/regional_dlp_flex.json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq "" }
    its(:stdout) { should include "gs://#{templates_bucket_name}/dataflow/flex_templates/regional_dlp_flex.json" }
  end

end
