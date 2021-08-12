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

set -e

apache_beam_version=$1
python_repository_url=$2

echo "apache_beam_version=${apache_beam_version}"
echo "python_repository_url=${python_repository_url}"

apt install unzip

pip3 install --no-cache-dir twine keyrings.google-artifactregistry-auth

mkdir -p artifact_registry_rep

pip3 download --dest=./artifact_registry_rep -r ./requirements.txt --no-deps --no-binary=:all:

pip3 download --dest=./artifact_registry_rep apache-beam=="${apache_beam_version}" --no-deps --no-binary=:all:

pip3 download --dest=./artifact_registry_rep apache-beam=="${apache_beam_version}" --no-deps --only-binary=:all: --python-version=37 --implementation=cp --abi=cp37m --platform=manylinux1_x86_64

# This 'unzip' and 'tar -czf' steps are necessary because Artifact Registry does not support .zip files, only .tar.gz files
# and Apache Beam sources are released as .zip files.
unzip -q "./artifact_registry_rep/apache-beam-${apache_beam_version}.zip"  -d ./artifact_registry_rep

tar -C ./artifact_registry_rep/  -czf "./artifact_registry_rep/apache-beam-${apache_beam_version}.tar.gz" "apache-beam-${apache_beam_version}"

rm -rf "./artifact_registry_rep/apache-beam-${apache_beam_version}.zip" "./artifact_registry_rep/apache-beam-${apache_beam_version}"

# this cannot be a direct upload of the whole ./artifact_registry_rep/ because Artifact Registry does not support the
# twine command line option --skip-existing to continue uploading files if one already exists.
# If a file already exist the upload fails, so we need the '|| true' to continua with the upload.
for python_module in "./artifact_registry_rep"/*
do
  twine upload --repository-url "${python_repository_url}" "$python_module" || true
done
