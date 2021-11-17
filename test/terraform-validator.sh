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

IFS=',' read -ra data_ingestion_projects <<< "$TF_VAR_data_ingestion_project_id"
data_ingestion_project_id_1=$(echo ${data_ingestion_projects[0]} | tr -d \" | tr -d \[ | tr -d \])
data_ingestion_project_number_1=$(gcloud projects describe ${data_ingestion_project_id_1} --format="value(projectNumber)")
data_ingestion_project_id_2=$(echo ${data_ingestion_projects[1]} | tr -d \" | tr -d \[ | tr -d \])
data_ingestion_project_number_2=$(gcloud projects describe ${data_ingestion_project_id_2} --format="value(projectNumber)")
data_ingestion_project_id_3=$(echo ${data_ingestion_projects[2]} | tr -d \" | tr -d \[ | tr -d \])
data_ingestion_project_number_3=$(gcloud projects describe ${data_ingestion_project_id_3} --format="value(projectNumber)")

IFS=',' read -ra data_ingestion_networks <<< "$TF_VAR_data_ingestion_network_self_link"
data_ingestion_network_1=$(echo ${data_ingestion_networks[0]} | tr -d \" | tr -d \[ | tr -d \])
data_ingestion_network_2=$(echo ${data_ingestion_networks[1]} | tr -d \" | tr -d \[ | tr -d \])
data_ingestion_network_3=$(echo ${data_ingestion_networks[2]} | tr -d \" | tr -d \[ | tr -d \])

IFS=',' read -ra data_governance_projects <<< "$TF_VAR_data_governance_project_id"
data_governance_project_id_1=$(echo ${data_governance_projects[0]} | tr -d \" | tr -d \[ | tr -d \])
data_governance_project_number_1=$(gcloud projects describe ${data_governance_project_id_1} --format="value(projectNumber)")
data_governance_project_id_2=$(echo ${data_governance_projects[1]} | tr -d \" | tr -d \[ | tr -d \])
data_governance_project_number_2=$(gcloud projects describe ${data_governance_project_id_2} --format="value(projectNumber)")
data_governance_project_id_3=$(echo ${data_governance_projects[2]} | tr -d \" | tr -d \[ | tr -d \])
data_governance_project_number_3=$(gcloud projects describe ${data_governance_project_id_3} --format="value(projectNumber)")

IFS=',' read -ra non_confidential_data_projects <<< "$TF_VAR_non_confidential_data_project_id"
non_confidential_data_project_id_1=$(echo ${non_confidential_data_projects[0]} | tr -d \" | tr -d \[ | tr -d \])
non_confidential_data_project_number_1=$(gcloud projects describe ${non_confidential_data_project_id_1} --format="value(projectNumber)")
non_confidential_data_project_id_2=$(echo ${non_confidential_data_projects[1]} | tr -d \" | tr -d \[ | tr -d \])
non_confidential_data_project_number_2=$(gcloud projects describe ${non_confidential_data_project_id_2} --format="value(projectNumber)")
non_confidential_data_project_id_3=$(echo ${non_confidential_data_projects[2]} | tr -d \" | tr -d \[ | tr -d \])
non_confidential_data_project_number_3=$(gcloud projects describe ${non_confidential_data_project_id_3} --format="value(projectNumber)")

IFS=',' read -ra confidential_projects <<< "$TF_VAR_confidential_data_project_id"
confidential_project_id_1=$(echo ${confidential_projects[0]} | tr -d \" | tr -d \[ | tr -d \])
confidential_project_number_1=$(gcloud projects describe ${confidential_project_id_1} --format="value(projectNumber)")
confidential_project_id_2=$(echo ${confidential_projects[1]} | tr -d \" | tr -d \[ | tr -d \])
confidential_project_number_2=$(gcloud projects describe ${confidential_project_id_2} --format="value(projectNumber)")
confidential_project_id_3=$(echo ${confidential_projects[2]} | tr -d \" | tr -d \[ | tr -d \])
confidential_project_number_3=$(gcloud projects describe ${confidential_project_id_3} --format="value(projectNumber)")

IFS=',' read -ra confidential_networks <<< "$TF_VAR_confidential_network_self_link"
confidential_network_1=$(echo ${confidential_networks[0]} | tr -d \" | tr -d \[ | tr -d \])
confidential_network_2=$(echo ${confidential_networks[1]} | tr -d \" | tr -d \[ | tr -d \])
confidential_network_3=$(echo ${confidential_networks[2]} | tr -d \" | tr -d \[ | tr -d \])


policy_file_path="$(pwd)/policy-library"
fixtures_path="test/fixtures"

for f in "${policy_file_path}"/policies/constraints/*.yaml ; do
    sed -i -e "s/NON_CONFIDENTIAL_DATA_PROJECT_ID_1/${non_confidential_data_project_id_1}/g" -e "s/NON_CONFIDENTIAL_DATA_PROJECT_ID_2/${non_confidential_data_project_id_2}/" -e "s/NON_CONFIDENTIAL_DATA_PROJECT_ID_3/${non_confidential_data_project_id_3}/" "${f}"
    sed -i -e "s/NON_CONFIDENTIAL_DATA_PROJECT_NUMBER_1/${non_confidential_data_project_number_1}/g" -e "s/NON_CONFIDENTIAL_DATA_PROJECT_NUMBER_2/${non_confidential_data_project_number_2}/" -e "s/NON_CONFIDENTIAL_DATA_PROJECT_NUMBER_3/${non_confidential_data_project_number_3}/" "${f}"
    sed -i -e "s/DATA_INGESTION_PROJECT_ID_1/${data_ingestion_project_id_1}/" -e "s/DATA_INGESTION_PROJECT_ID_2/${data_ingestion_project_id_2}/" -e "s/DATA_INGESTION_PROJECT_ID_3/${data_ingestion_project_id_3}/" "${f}"
    sed -i -e "s/DATA_INGESTION_PROJECT_NUMBER_1/${data_ingestion_project_number_1}/" -e "s/DATA_INGESTION_PROJECT_NUMBER_2/${data_ingestion_project_number_2}/" -e "s/DATA_INGESTION_PROJECT_NUMBER_3/${data_ingestion_project_number_3}/" "${f}"
    sed -i -e "s/DATA_GOVERNANCE_PROJECT_ID_1/${data_governance_project_id_1}/" -e "s/DATA_GOVERNANCE_PROJECT_ID_2/${data_governance_project_id_2}/" -e "s/DATA_GOVERNANCE_PROJECT_ID_3/${data_governance_project_id_3}/" "${f}"
    sed -i -e "s/DATA_GOVERNANCE_PROJECT_NUMBER_1/${data_governance_project_number_1}/" -e "s/DATA_GOVERNANCE_PROJECT_NUMBER_2/${data_governance_project_number_2}/" -e "s/DATA_GOVERNANCE_PROJECT_NUMBER_3/${data_governance_project_number_3}/" "${f}"
    sed -i -e "s/CONFIDENTIAL_PROJECT_ID_1/${confidential_project_id_1}/" -e "s/CONFIDENTIAL_PROJECT_ID_2/${confidential_project_id_2}/" -e "s/CONFIDENTIAL_PROJECT_ID_3/${confidential_project_id_3}/" "${f}"
    sed -i -e "s/CONFIDENTIAL_PROJECT_NUMBER_1/${confidential_project_number_1}/" -e "s/CONFIDENTIAL_PROJECT_NUMBER_2/${confidential_project_number_2}/" -e "s/CONFIDENTIAL_PROJECT_NUMBER_3/${confidential_project_number_3}/" "${f}"
    sed -i -e "s@DATA_INGESTION_NETWORK_1@${data_ingestion_network_1}@" -e "s@DATA_INGESTION_NETWORK_2@${data_ingestion_network_2}@" -e "s@DATA_INGESTION_NETWORK_3@${data_ingestion_network_3}@" "${f}"
    sed -i -e "s@CONFIDENTIAL_NETWORK_1@${confidential_network_1}@" -e "s@CONFIDENTIAL_NETWORK_2@${confidential_network_2}@" -e "s@CONFIDENTIAL_NETWORK_3@${confidential_network_3}@" "${f}"
done

source /usr/local/bin/test_validator.sh "${fixtures_path}/${tf_example}" "${data_ingestion_project_id_1}" "${policy_file_path}"
