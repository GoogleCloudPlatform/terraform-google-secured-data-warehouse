#!/bin/bash

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
#
# Important information for understanding the script:
# https://cloud.google.com/kms/docs/encrypt-decrypt
# https://cloud.google.com/secret-manager/docs/creating-and-accessing-secrets

set -e

terraform_service_account=$1
key=$2
secret_name=$3
project_id=$4

access_token=$(gcloud auth print-access-token --impersonate-service-account="${terraform_service_account}")

data=$(python -c "import os,base64; key=os.urandom(32); encoded_key = base64.b64encode(key).decode('utf-8'); print(encoded_key)")

response_kms=$(curl -s -X POST "https://cloudkms.googleapis.com/v1/${key}:encrypt" \
 -d '{"plaintext":"'"$data"'"}' \
 -H "Authorization:Bearer ${access_token}" \
 -H "Content-Type:application/json" \
 | python -c "import sys, json; print(\"\".join(json.load(sys.stdin)['ciphertext']))")

echo "${response_kms}" | \
    gcloud secrets versions add "${secret_name}" \
    --data-file=- \
    --impersonate-service-account="${terraform_service_account}" \
    --project="${project_id}"
