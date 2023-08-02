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

		projects := []string{dataGovprojectID, dataIngprojectID, nonConfprojectID, confprojectID}

		for _, project := range projects {
			opProject := gcloud.Runf(t, "projects describe %s", project)
			assert.Equal(project, opProject.Get("projectId").String(), "should have expected projectID ")
		}

		gcloudArgsBucket := gcloud.WithCommonArgs([]string{"--project", dataIngprojectID, "--json"})
		bucketName := standalone.GetStringOutput("data_ingestion_bucket_name")
		opBucket := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", bucketName), gcloudArgsBucket).Array()
		assert.Equal(bucketName, opBucket[0].Get("metadata.name").String(), "has expected name ")

		dataIngTopicName := standalone.GetStringOutput("data_ingestion_topic_name")
		opPubsub := gcloud.Runf(t, "pubsub topics describe %s --project=%s", dataIngTopicName, dataIngprojectID)
		assert.Equal(fmt.Sprintf("projects/%s/topics/%s", dataIngprojectID, dataIngTopicName), opPubsub.Get("name").String(), "has expected name")

		taxonomyLocation := "us-east4"
		taxonomyName := standalone.GetStringOutput("taxonomy_display_name")
		optaxonomy := gcloud.Runf(t, "data-catalog taxonomies list --location=%s --project=%s", taxonomyLocation, dataGovprojectID).Array()
		assert.Equal(taxonomyName, optaxonomy[0].Get("displayName").String(), "has expected name")
		assert.NotEqual("0", optaxonomy[0].Get("policyTagCount").String(), "taxonomy contains policy tags")

		confTableName := standalone.GetStringOutput("bigquery_confidential_table")
		confdatasetID := standalone.GetStringOutput("confidential_dataset")
		opconfdataset := gcloud.Runf(t, "alpha bq tables describe irs_990_ein_re_id --dataset %s --project %s", confdatasetID, confprojectID)
		assert.Equal(confTableName, opconfdataset.Get("id").String(), "has expected name")

		opconftabledata := gcloud.Runf(t, "alpha bq show --format=prettyjson %s:%s.%s", confprojectID, confdatasetID, confTableName)
		assert.NotEqual("0", opconftabledata.Get("numRows").String(), "table contains data")

		nonconfTableName := standalone.GetStringOutput("bigquery_non_confidential_table")
		nonconfdatasetID := standalone.GetStringOutput("non_confidential_dataset")
		opnonconfdataset := gcloud.Runf(t, "alpha bq tables describe irs_990_ein_re_id --dataset %s --project %s", nonconfdatasetID, nonconfprojectID)
		assert.Equal(nonconfTableName, opnonconfdataset.Get("id").String(), "has expected name")

		opnonconftabledata := gcloud.Runf(t, "alpha bq show --format=prettyjson %s:%s.%s", nonConfprojectID, nonconfdatasetID, nonconfTableName)
		assert.NotEqual("0", opnonconftabledata.Get("numRows").String(), "table contains data")
	})

	standalone.Test()

}
