package standalone

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestStandalone(t *testing.T) {
	standalone := tft.NewTFBlueprintTest(t)

	standalone.DefineVerify(func(assert *assert.Assertions) {
		standalone.DefaultVerify(assert)

		dataGovprojectID := standalone.GetStringOutput("data_governance_project_id")
		dataIngprojectID := standalone.GetStringOutput("data_ingestion_project_id")
		nonConfprojectID := standalone.GetStringOutput("non_confidential_data_project_id")
		confprojectID := standalone.GetStringOutput("confidential_data_project_id")
		bucketName := standalone.GetStringOutput("data_ingestion_bucket_name")
		dataIngTopicName := standalone.GetStringOutput("data_ingestion_topic_name")
		nonConfTableName := standalone.GetStringOutput("bigquery_non_confidential_table")
		confTableName := standalone.GetStringOutput("bigquery_confidential_table")
		nonConfdatasetID := standalone.GetStringOutput("non_confidential_dataset")
		confdatasetID := standalone.GetStringOutput("confidential_dataset")

		gcloudArgs := gcloud.WithCommonArgs([]string{"--format", "json"})
		gcloudArgsBucket := gcloud.WithCommonArgs([]string{"--project", dataIngprojectID, "--json"})

		opdataGov := gcloud.Run(t, fmt.Sprintf("projects describe %s", dataGovprojectID), gcloudArgs)
		assert.Equal(dataGovprojectID, opdataGov.Get("projectId").String(), "should have expected projectID ")

		opdataIng := gcloud.Run(t, fmt.Sprintf("projects describe %s", dataIngprojectID), gcloudArgs)
		assert.Equal(dataIngprojectID, opdataIng.Get("projectId").String(), "should have expected projectID ")

		opnonConf := gcloud.Run(t, fmt.Sprintf("projects describe %s", nonConfprojectID), gcloudArgs)
		assert.Equal(nonConfprojectID, opnonConf.Get("projectId").String(), "should have expected projectID ")

		opConf := gcloud.Run(t, fmt.Sprintf("projects describe %s", confprojectID), gcloudArgs)
		assert.Equal(confprojectID, opConf.Get("projectId").String(), "should have expected projectID ")

		opBucket := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", bucketName), gcloudArgsBucket)
		assert.Equal(fmt.Sprintf("standalone-data-ing"), opBucket.Get("metadata.name").String(), "has expected name ")

		opPubsub := gcloud.Run(t, fmt.Sprintf("pubsub topics describe %s --project=%s", dataIngTopicName, dataIngprojectID))
		assert.Equal(fmt.Sprintf("projects/%s/topics/%s", dataIngprojectID, dataIngTopicName), opPubsub.Get("name").String(), "has expected name")

		opnonConfdataset := gcloud.Run(t, fmt.Sprintf("alpha bq tables describe %s --dataset %s", nonConfTableName, nonConfdatasetID), gcloudArgs)
		assert.Equal(fmt.Sprintf("%s:%s.%s", nonConfprojectID, nonConfdatasetID, nonConfTableName), opnonConfdataset.Get("id").String(), "has expected name")

		opconfdataset := gcloud.Run(t, fmt.Sprintf("alpha bq tables describe %s --dataset %s", confTableName, confdatasetID), gcloudArgs)
		assert.Equal(fmt.Sprintf("%s:%s.%s", confprojectID, confdatasetID, confTableName), opconfdataset.Get("id").String(), "has expected name")
	})

	standalone.Test()
}
