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
export project=$(echo ${projects[0]} | tr -d \" | tr -d \[ | tr -d \])
export policy_file_path="$(pwd)/policy-library"
export fixtures_path="test/fixtures"

source /usr/local/bin/test_validator.sh "${fixtures_path}/${tf_example_path}" "${project}" "${policy_file_path}"
