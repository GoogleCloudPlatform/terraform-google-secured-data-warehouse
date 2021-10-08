#!/usr/bin/env bash

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/usr/bin/env bash

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

tf_example=$1

IFS=',' read -ra projects <<< "$TF_VAR_data_ingestion_project_id"
export project=${projects[0]:2:-2}
export base_dir=$(pwd)
export tmp_plan="${base_dir}/tmp_plan"
export policy_file_path="${base_dir}/policy-library"
export path="${base_dir}/test/fixtures/${tf_example}"
export setup="${base_dir}/test/setup"


echo "*************** TERRAFORM VALIDATE ******************"
echo "      At example: ${tf_example}"
echo "      Using policy from: ${policy_file_path} "
echo "      at project: ${project}"
echo "*****************************************************"

if ! command -v terraform-validator &> /dev/null; then
    gsutil cp gs://terraform-validator/releases/v0.9.1/terraform-validator_linux_amd64-0.9.1.tar.gz .
    tar -xzvf terraform-validator_linux_amd64-0.9.1.tar.gz
    chmod +X terraform-validator
    mv terraform-validator /usr/bin/
    rm terraform-validator_linux_amd64-0.9.1.tar.gz
fi

if [ ! -d "$tmp_plan" ]; then
    mkdir "$tmp_plan/" || exit 29
fi

if [ -z "$policy_file_path" ]; then
    echo "no policy repo found! Check the argument provided for policysource to this script."
    echo "https://github.com/GoogleCloudPlatform/terraform-validator/blob/main/docs/policy_library.md"
else
    if [ -d "$path" ]; then

        cd "$path" || exit 30

        terraform plan -input=false -out "${tmp_plan}/${tf_example}.tfplan"  || exit 31
        terraform show -json "${tmp_plan}/${tf_example}.tfplan" > "${tf_example}.json" || exit 32

        terraform-validator validate "${tf_example}.json" --policy-path="${policy_file_path}" --project="${project}" || exit 33

        cd "$base_dir" || exit
    else
      echo "ERROR:  ${path} does not exist"
    fi
fi