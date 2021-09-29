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

data_ingest_bucket_name = attribute('data_ingest_bucket_name')
data_ingest_topic_name = attribute('data_ingest_topic_name')
project_id = attribute('project_id')
data_governance_project_id = attribute('data_governance_project_id')
datalake_project_id = attribute('datalake_project_id')
service_perimeter_name = attribute('service_perimeter_name')
service_perimeter_title = service_perimeter_name.split('/')[-1]
access_level_name = attribute('access_level_name')
organization_policy_name = attribute('organization_policy_name')
cmek_location = 'us-east4'
cmek_keyring_name = attribute('cmek_keyring_name')
cmek_ingestion_crypto_key_name = attribute('cmek_ingestion_crypto_key_name')
cmek_bigquery_crypto_key_name = attribute('cmek_bigquery_crypto_key_name')

restricted_googleapis_cidr = '199.36.153.4/30'
private_googleapis_cidr = '199.36.153.8/30'

restricted_services = ['pubsub.googleapis.com', 'bigquery.googleapis.com', 'storage.googleapis.com', 'dataflow.googleapis.com']

other_kms_roles = [
  'roles/cloudkms.admin',
  'roles/cloudkms.publicKeyViewer',
  'roles/cloudkms.signer',
  'roles/cloudkms.signerVerifier',
  'roles/cloudkms.importer',
  'roles/cloudkms.serviceAgent',
  'roles/cloudkms.cryptoKeyEncrypterDecrypter'
]

control 'gcp' do
  title 'GCP Resources'

  describe google_storage_bucket(name: data_ingest_bucket_name) do
    it { should exist }
  end

  describe google_pubsub_topic(project: project_id, name: data_ingest_topic_name) do
    it { should exist }
  end

  describe google_access_context_manager_access_level(parent: organization_policy_name, name: access_level_name) do
    it { should exist }
    its('title') { should cmp access_level_name }
  end

  describe google_access_context_manager_service_perimeter(policy_name: organization_policy_name, name: service_perimeter_title) do
    it { should exist }
    its('title') { should cmp service_perimeter_title }

    restricted_services.each do |service|
      its('status.restricted_services') { should include service }
    end

    its('status.access_levels') { should include "accessPolicies/#{organization_policy_name}/accessLevels/#{access_level_name}" }
  end

  describe google_kms_key_ring(project: data_governance_project_id, location: cmek_location, name: cmek_keyring_name) do
    it { should exist }
    its('key_ring_name') { should eq cmek_keyring_name }
    its('key_ring_url') { should match cmek_keyring_name }
  end

  describe google_kms_crypto_key(
    project: data_governance_project_id,
    location: cmek_location,
    key_ring_name: cmek_keyring_name,
    name: cmek_ingestion_crypto_key_name
  ) do
    it { should exist }
    its('crypto_key_name') { should cmp cmek_ingestion_crypto_key_name }
    its('primary_state') { should eq 'ENABLED' }
    its('purpose') { should eq 'ENCRYPT_DECRYPT' }
  end

  describe google_kms_crypto_key_iam_binding(
    project: data_governance_project_id,
    location: cmek_location,
    key_ring_name: cmek_keyring_name,
    crypto_key_name: cmek_ingestion_crypto_key_name,
    role: 'roles/cloudkms.cryptoKeyDecrypter'
  ) do
    it { should exist }
  end

  describe google_kms_crypto_key_iam_binding(
    project: data_governance_project_id,
    location: cmek_location,
    key_ring_name: cmek_keyring_name,
    crypto_key_name: cmek_ingestion_crypto_key_name,
    role: 'roles/cloudkms.cryptoKeyEncrypter'
  ) do
    it { should exist }
  end

  describe google_kms_crypto_key(
    project: data_governance_project_id,
    location: cmek_location,
    key_ring_name: cmek_keyring_name,
    name: cmek_bigquery_crypto_key_name
  ) do
    it { should exist }
    its('crypto_key_name') { should cmp cmek_bigquery_crypto_key_name }
    its('primary_state') { should eq 'ENABLED' }
    its('purpose') { should eq 'ENCRYPT_DECRYPT' }
  end

  describe google_kms_crypto_key_iam_binding(
    project: data_governance_project_id,
    location: cmek_location,
    key_ring_name: cmek_keyring_name,
    crypto_key_name: cmek_bigquery_crypto_key_name,
    role: 'roles/cloudkms.cryptoKeyDecrypter'
  ) do
    it { should exist }
  end

  describe google_kms_crypto_key_iam_binding(
    project: data_governance_project_id,
    location: cmek_location,
    key_ring_name: cmek_keyring_name,
    crypto_key_name: cmek_bigquery_crypto_key_name,
    role: 'roles/cloudkms.cryptoKeyEncrypter'
  ) do
    it { should exist }
  end

  google_project_iam_policy(project: project_id).iam_binding_roles.each do |iam_binding_role|
    next unless other_kms_roles.include?(iam_binding_role)

    describe google_project_iam_binding(project: project_id, role: iam_binding_role) do
      it { should exist }
    end
  end

  google_kms_crypto_key_iam_policy(
    project: data_governance_project_id,
    location: cmek_location,
    key_ring_name: cmek_keyring_name,
    crypto_key_name: cmek_ingestion_crypto_key_name
  ).iam_binding_roles.each do |iam_binding_role|
    next unless other_kms_roles.include?(iam_binding_role)

    describe google_kms_crypto_key_iam_binding(
      project: data_governance_project_id,
      location: cmek_location,
      key_ring_name: cmek_keyring_name,
      crypto_key_name: cmek_ingestion_crypto_key_name,
      role: iam_binding_role
    ) do
      it { should exist }
    end
  end

  google_kms_crypto_key_iam_policy(
    project: data_governance_project_id,
    location: cmek_location,
    key_ring_name: cmek_keyring_name,
    crypto_key_name: cmek_bigquery_crypto_key_name
  ).iam_binding_roles.each do |iam_binding_role|
    next unless other_kms_roles.include?(iam_binding_role)

    describe google_kms_crypto_key_iam_binding(
      project: data_governance_project_id,
      location: cmek_location,
      key_ring_name: cmek_keyring_name,
      crypto_key_name: cmek_bigquery_crypto_key_name,
      role: iam_binding_role
    ) do
      it { should exist }
    end
  end
end
