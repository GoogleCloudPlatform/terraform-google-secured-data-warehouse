package standalone_bucket

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestStandaloneBucket(t *testing.T) {
	buckets := tft.NewTFBlueprintTest(t)
	//buckets := tft.NewTFBlueprintTest(t,
	//	tft.WithTFDir("../fixtures/standalone"),
	//)

	buckets.DefineVerify(func(assert *assert.Assertions) {
		buckets.DefaultVerify(assert)

		projectID := buckets.GetStringOutput("project_id")
		names := terraform.OutputList(t, buckets.GetTFOptions(), "names_list")

		for _, bucketName := range names {
			// alpha command to list buckets has --json instead of format=json
			gcloudArgs := gcloud.WithCommonArgs([]string{"--project", projectID, "--json"})

			op := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", bucketName), gcloudArgs).Array()[0]
			assert.Equal(t, fmt.Sprintf("standalone-data-ing"), op.Get("metadata.name").String(), "has expected name ")
		}
	})

	buckets.Test()
}
