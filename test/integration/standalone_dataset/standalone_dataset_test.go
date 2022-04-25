package standalone_dataset

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestStandaloneDataset(t *testing.T) {
	dataset := tft.NewTFBlueprintTest(t)

	dataset.DefineVerify(func(assert *assert.Assertions) {
		dataset.DefaultVerify(assert)

		projectID := dataset.GetStringOutput("project_id")
		gcloudArgs := gcloud.WithCommonArgs([]string{"--project", projectID, "--format", "json"})

		opdataset := gcloud.Run(t, fmt.Sprintf("alpha bq tables describe irs_990_ein_re_id --dataset secured_dataset"), gcloudArgs)
		assert.Equal(t, fmt.Sprintf("%s:secured_dataset.irs_990_ein_re_id", projectId), opdataset.Get("id").String(), "has expected name")

		opconfdataset := gcloud.Run(t, fmt.Sprintf("alpha bq tables describe irs_990_ein_re_id --dataset secured_dataset"), gcloudArgs)
		assert.Equal(t, fmt.Sprintf("%s:secured_dataset.irs_990_ein_re_id", projectId), opconfdataset.Get("id").String(), "has expected name")
	})

	dataset.Test()
}
