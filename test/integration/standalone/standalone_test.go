// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package standalone

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
)

func getPolicyID(t *testing.T, orgID string) string {
	gcOpts := gcloud.WithCommonArgs([]string{"--format", "value(name)"})
	op := gcloud.Run(t, fmt.Sprintf("access-context-manager policies list --organization=%s ", orgID), gcOpts)
	return op.String()
}

func TestStandalone(t *testing.T) {
	orgID := utils.ValFromEnv(t, "TF_VAR_org_id")
	policyID := getPolicyID(t, orgID)

	vars := map[string]interface{}{
		"access_context_manager_policy_id": policyID,
	}

	standalone := tft.NewTFBlueprintTest(t,
		tft.WithVars(vars),
	)

	standalone.DefineVerify(func(assert *assert.Assertions) {

		dataGovprojectID := standalone.GetStringOutput("data_governance_project_id")
		dataIngprojectID := standalone.GetStringOutput("data_ingestion_project_id")
		nonConfprojectID := standalone.GetStringOutput("non_confidential_data_project_id")
		confprojectID := standalone.GetStringOutput("confidential_data_project_id")
		terraformSa := standalone.GetStringOutput("terraform_service_account")
		kmsKeyRingName := standalone.GetStringOutput("cmek_keyring_name")
		kmsKeyDataIngestion := standalone.GetStringOutput("cmek_data_ingestion_crypto_key")

		projects := []string{dataGovprojectID, dataIngprojectID, nonConfprojectID, confprojectID}

		for _, project := range projects {
			opProject := gcloud.Runf(t, "projects describe %s", project)
			assert.Equal(project, opProject.Get("projectId").String(), "should have expected projectID ")
		}

		kmsKeyDataBqName := standalone.GetStringOutput("cmek_bigquery_crypto_key_name")
		expectedKmsKeyDataBq := standalone.GetStringOutput("cmek_bigquery_crypto_key")
		opKMSDataBq := gcloud.Runf(t, "kms keys describe %s --keyring=%s --project=%s --location us-east4 --impersonate-service-account=%s", kmsKeyDataBqName, kmsKeyRingName, dataGovprojectID, terraformSa)
		assert.Equal(expectedKmsKeyDataBq, opKMSDataBq.Get("name").String(), fmt.Sprintf("should have key %s", expectedKmsKeyDataBq))

		kmsKeyConfidentialBqName := standalone.GetStringOutput("cmek_confidential_bigquery_crypto_key_name")
		expectedKmsKeyConfidentialBq := standalone.GetStringOutput("cmek_confidential_bigquery_crypto_key")
		opKMSDataConfBq := gcloud.Runf(t, "kms keys describe %s --keyring=%s --project=%s --location us-east4 --impersonate-service-account=%s", kmsKeyConfidentialBqName, kmsKeyRingName, dataGovprojectID, terraformSa)
		assert.Equal(expectedKmsKeyConfidentialBq, opKMSDataConfBq.Get("name").String(), fmt.Sprintf("should have key %s", expectedKmsKeyConfidentialBq))

		kmsKeyDataIngestionName := standalone.GetStringOutput("cmek_data_ingestion_crypto_key_name")
		expectedKmsKeyDataIngestion := standalone.GetStringOutput("cmek_data_ingestion_crypto_key")
		opKMSDataIngestion := gcloud.Runf(t, "kms keys describe %s --keyring=%s --project=%s --location us-east4 --impersonate-service-account=%s", kmsKeyDataIngestionName, kmsKeyRingName, dataGovprojectID, terraformSa)
		assert.Equal(expectedKmsKeyDataIngestion, opKMSDataIngestion.Get("name").String(), fmt.Sprintf("should have key %s", expectedKmsKeyDataIngestion))

		kmsKeyReidentificationName := standalone.GetStringOutput("cmek_reidentification_crypto_key_name")
		expectedKmsKeyReidentification := standalone.GetStringOutput("cmek_reidentification_crypto_key")
		opKMSReidentification := gcloud.Runf(t, "kms keys describe %s --keyring=%s --project=%s --location us-east4 --impersonate-service-account=%s", kmsKeyReidentificationName, kmsKeyRingName, dataGovprojectID, terraformSa)
		assert.Equal(expectedKmsKeyReidentification, opKMSReidentification.Get("name").String(), fmt.Sprintf("should have key %s", expectedKmsKeyReidentification))

		gcloudArgsBucketLog := gcloud.WithCommonArgs([]string{"--project", dataGovprojectID, "--json"})
		bucketNameLog := standalone.GetStringOutput("centralized_logging_bucket_name")
		opBucketLog := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s --impersonate-service-account=%s", bucketNameLog, terraformSa), gcloudArgsBucketLog).Array()
		assert.Equal(bucketNameLog, opBucketLog[0].Get("metadata.name").String(), fmt.Sprintf("Should have the expected name:%s", bucketNameLog))
		assert.Equal("US-EAST4", opBucketLog[0].Get("metadata.location").String(), "Should be in the US-EAST4 location.")

		gcloudArgsBucketReid := gcloud.WithCommonArgs([]string{"--project", confprojectID, "--json"})
		bucketNameDataflowReid := standalone.GetStringOutput("confidential_data_dataflow_bucket_name")
		kmsKeyReidentification := standalone.GetStringOutput("cmek_reidentification_crypto_key")
		opBucketDataflowReid := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s --impersonate-service-account=%s", bucketNameDataflowReid, terraformSa), gcloudArgsBucketReid).Array()
		assert.Equal(bucketNameDataflowReid, opBucketDataflowReid[0].Get("metadata.name").String(), fmt.Sprintf("Should have the expected name:%s", bucketNameDataflowReid))
		assert.Equal("US-EAST4", opBucketDataflowReid[0].Get("metadata.location").String(), "Should be in the US-EAST4 location.")
		assert.Equal(kmsKeyReidentification, opBucketDataflowReid[0].Get("metadata.encryption.defaultKmsKeyName").String(), fmt.Sprintf("Should have kms key: %s", kmsKeyReidentification))

		gcloudArgsBucketDataflowDeid := gcloud.WithCommonArgs([]string{"--project", dataIngprojectID, "--json"})
		bucketNameDataflowDeid := standalone.GetStringOutput("data_ingestion_dataflow_bucket_name")
		opBucketDataflowDeid := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s --impersonate-service-account=%s", bucketNameDataflowDeid, terraformSa), gcloudArgsBucketDataflowDeid).Array()
		assert.Equal(bucketNameDataflowDeid, opBucketDataflowDeid[0].Get("metadata.name").String(), fmt.Sprintf("Should have the expected name:%s", bucketNameDataflowDeid))
		assert.Equal("US-EAST4", opBucketDataflowDeid[0].Get("metadata.location").String(), "Should be in the US-EAST4 location.")
		assert.Equal(kmsKeyDataIngestion, opBucketDataflowDeid[0].Get("metadata.encryption.defaultKmsKeyName").String(), fmt.Sprintf("Should have kms key: %s", kmsKeyDataIngestion))

		gcloudArgsBucketDataingestion := gcloud.WithCommonArgs([]string{"--project", dataIngprojectID, "--json"})
		bucketNameDataingestion := standalone.GetStringOutput("data_ingestion_bucket_name")
		opBucketDataingestion := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s --impersonate-service-account=%s", bucketNameDataingestion, terraformSa), gcloudArgsBucketDataingestion).Array()
		assert.Equal(bucketNameDataingestion, opBucketDataingestion[0].Get("metadata.name").String(), fmt.Sprintf("Should have the expected name:%s", bucketNameDataingestion))
		assert.Equal("US-EAST4", opBucketDataingestion[0].Get("metadata.location").String(), "Should be in the US-EAST4 location.")
		assert.Equal(kmsKeyDataIngestion, opBucketDataingestion[0].Get("metadata.encryption.defaultKmsKeyName").String(), fmt.Sprintf("Should have kms key: %s", kmsKeyDataIngestion))

		dataIngTopicName := standalone.GetStringOutput("data_ingestion_topic_name")
		opPubsub := gcloud.Runf(t, "pubsub topics describe %s --project=%s --impersonate-service-account=%s", dataIngTopicName, dataIngprojectID, terraformSa)
		expectedTopicName := fmt.Sprintf("projects/%s/topics/%s", dataIngprojectID, dataIngTopicName)
		assert.Equal(expectedTopicName, opPubsub.Get("name").String(), fmt.Sprintf("Should have topic name: %s", expectedTopicName))
		assert.Equal(kmsKeyDataIngestion, opPubsub.Get("kmsKeyName").String(), fmt.Sprintf("Should have kms key: %s", kmsKeyDataIngestion))

		confDatasetLocation := "us-east4"
		opConfDataset := gcloud.Runf(t, "alpha bq tables describe irs_990_ein_re_id --dataset secured_dataset --project %s --impersonate-service-account=%s", confprojectID, terraformSa)
		confFullTablePath := fmt.Sprintf("%s:secured_dataset.irs_990_ein_re_id", confprojectID)
		assert.Equal(confFullTablePath, opConfDataset.Get("id").String(), fmt.Sprintf("Should have same id: %s", confFullTablePath))
		assert.Equal(confDatasetLocation, opConfDataset.Get("location").String(), fmt.Sprintf("Should have same location: %s", confDatasetLocation))
		assert.NotEqual("0", opConfDataset.Get("numRows").String(), fmt.Sprintf("Table should contains data: %s", opConfDataset.Get("numRows").String()))

		nonConfDatasetLocation := "us-east4"
		opNonConfDataset := gcloud.Runf(t, "alpha bq tables describe irs_990_ein_de_id --dataset non_confidential_dataset --project %s --impersonate-service-account=%s", nonConfprojectID, terraformSa)
		nonconfFullTablePath := fmt.Sprintf("%s:non_confidential_dataset.irs_990_ein_de_id", nonConfprojectID)
		assert.Equal(nonconfFullTablePath, opNonConfDataset.Get("id").String(), fmt.Sprintf("Should have same id: %s", nonconfFullTablePath))
		assert.Equal(nonConfDatasetLocation, opNonConfDataset.Get("location").String(), fmt.Sprintf("Should have same location: %s", nonConfDatasetLocation))
		assert.NotEqual("0", opNonConfDataset.Get("numRows").String(), fmt.Sprintf("Table should contains data: %s", opNonConfDataset.Get("numRows").String()))

		taxonomyName := standalone.GetStringOutput("taxonomy_display_name")
		opTaxonomies := gcloud.Runf(t, "data-catalog taxonomies list --location us-east4 --project %s  --impersonate-service-account=%s", dataGovprojectID, terraformSa).Array()
		assert.Equal(taxonomyName, opTaxonomies[0].Get("displayName").String(), fmt.Sprintf("Should have same name: %s", taxonomyName))
		assert.NotEqual("0", opTaxonomies[0].Get("policyTagCount").String(), fmt.Sprintf("Taxonomy should contains policy tags %s", opTaxonomies[0].Get("policyTagCount").String()))

		denyAllEgressName := "fw-e-shared-restricted-65535-e-d-all-all-all"
		denyAllEgressRule := gcloud.Runf(t, "compute firewall-rules describe %s --project %s", denyAllEgressName, dataIngprojectID)
		assert.Equal(denyAllEgressName, denyAllEgressRule.Get("name").String(), fmt.Sprintf("Firewall rule %s should exist", denyAllEgressName))
		assert.Equal("EGRESS", denyAllEgressRule.Get("direction").String(), fmt.Sprintf("Firewall rule %s direction should be EGRESS", denyAllEgressName))
		assert.True(denyAllEgressRule.Get("logConfig.enable").Bool(), fmt.Sprintf("Firewall rule %s should have log configuration enabled", denyAllEgressName))
		assert.Equal("0.0.0.0/0", denyAllEgressRule.Get("destinationRanges").Array()[0].String(), fmt.Sprintf("Firewall rule %s destination ranges should be 0.0.0.0/0", denyAllEgressName))
		assert.Equal(1, len(denyAllEgressRule.Get("denied").Array()), fmt.Sprintf("Firewall rule %s should have only one denied", denyAllEgressName))
		assert.Equal(1, len(denyAllEgressRule.Get("denied.0").Map()), fmt.Sprintf("Firewall rule %s should have only one denied only with no ports", denyAllEgressName))
		assert.Equal("all", denyAllEgressRule.Get("denied.0.IPProtocol").String(), fmt.Sprintf("Firewall rule %s should deny all protocols", denyAllEgressName))

		allowApiEgressRestrictedName := "fw-e-shared-restricted-65534-e-a-allow-google-apis-all-tcp-443"
		allowApiEgressRestrictedRule := gcloud.Runf(t, "compute firewall-rules describe %s --project %s", allowApiEgressRestrictedName, dataIngprojectID)
		assert.Equal(allowApiEgressRestrictedName, allowApiEgressRestrictedRule.Get("name").String(), fmt.Sprintf("Firewall rule %s should exist", allowApiEgressRestrictedName))
		assert.Equal("EGRESS", allowApiEgressRestrictedRule.Get("direction").String(), fmt.Sprintf("Firewall rule %s direction should be EGRESS", allowApiEgressRestrictedName))
		assert.True(allowApiEgressRestrictedRule.Get("logConfig.enable").Bool(), fmt.Sprintf("Firewall rule %s should have log configuration enabled", allowApiEgressRestrictedName))
		assert.Equal(1, len(allowApiEgressRestrictedRule.Get("allowed").Array()), fmt.Sprintf("Firewall rule %s should have only one allowed", allowApiEgressRestrictedName))
		assert.Equal(2, len(allowApiEgressRestrictedRule.Get("allowed.0").Map()), fmt.Sprintf("Firewall rule %s should have only one allowed only with protocol end ports", allowApiEgressRestrictedName))
		assert.Equal("tcp", allowApiEgressRestrictedRule.Get("allowed.0.IPProtocol").String(), fmt.Sprintf("Firewall rule %s should allow tcp protocol", allowApiEgressRestrictedName))
		assert.Equal(1, len(allowApiEgressRestrictedRule.Get("allowed.0.ports").Array()), fmt.Sprintf("Firewall rule %s should allow only one port", allowApiEgressRestrictedName))
		assert.Equal("443", allowApiEgressRestrictedRule.Get("allowed.0.ports.0").String(), fmt.Sprintf("Firewall rule %s should allow port 443", allowApiEgressRestrictedName))

		allowApiEgressPrivateName := "fw-e-shared-private-65533-e-a-allow-google-apis-all-tcp-443"
		allowApiEgressPrivateRule := gcloud.Runf(t, "compute firewall-rules describe %s --project %s", allowApiEgressPrivateName, dataIngprojectID)
		assert.Equal(allowApiEgressPrivateName, allowApiEgressPrivateRule.Get("name").String(), fmt.Sprintf("Firewall rule %s should exist", allowApiEgressPrivateName))
		assert.Equal("EGRESS", allowApiEgressPrivateRule.Get("direction").String(), fmt.Sprintf("Firewall rule %s direction should be EGRESS", allowApiEgressPrivateName))
		assert.True(allowApiEgressPrivateRule.Get("logConfig.enable").Bool(), fmt.Sprintf("Firewall rule %s should have log configuration enabled", allowApiEgressPrivateName))
		assert.Equal(1, len(allowApiEgressPrivateRule.Get("allowed").Array()), fmt.Sprintf("Firewall rule %s should have only one allowed", allowApiEgressPrivateName))
		assert.Equal(2, len(allowApiEgressPrivateRule.Get("allowed.0").Map()), fmt.Sprintf("Firewall rule %s should have only one allowed only with protocol end ports", allowApiEgressPrivateName))
		assert.Equal("tcp", allowApiEgressPrivateRule.Get("allowed.0.IPProtocol").String(), fmt.Sprintf("Firewall rule %s should allow tcp protocol", allowApiEgressPrivateName))
		assert.Equal(1, len(allowApiEgressPrivateRule.Get("allowed.0.ports").Array()), fmt.Sprintf("Firewall rule %s should allow only one port", allowApiEgressPrivateName))
		assert.Equal("443", allowApiEgressPrivateRule.Get("allowed.0.ports.0").String(), fmt.Sprintf("Firewall rule %s should allow port 443", allowApiEgressPrivateName))
	})

	standalone.Test()

}
