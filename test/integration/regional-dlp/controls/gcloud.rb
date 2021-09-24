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

template_full_path = attribute('template_full_path')

control 'gcloud' do
  title 'Gcloud Resources'

  describe command("curl -s -X GET -H \"Authorization: Bearer $(gcloud auth application-default print-access-token)\" https://dlp.googleapis.com/v2/#{template_full_path}") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "de-identification Template #{template_full_path}" do
      it 'should exist' do
        expect(data).to_not be_empty
      end
    end
  end
end
