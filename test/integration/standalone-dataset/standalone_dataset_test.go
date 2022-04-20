package standalone_dataset

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/stretchr/testify/assert"
)

func TestTemp(t *testing.T) {
	projectId := "prj-feature-standalone"
	gcloudArgs := gcloud.WithCommonArgs([]string{"--project", projectId, "--format", "json"})

	op1 := gcloud.Run(t, fmt.Sprintf("alpha bq tables describe tbl-prj-feature-standalone --dataset dtwh_dataset"), gcloudArgs)
	assert.Equal(t, fmt.Sprintf("prj-feature-standalone:dtwh_dataset.tbl-prj-feature-standalone"), op1.Get("id").String(), "has expected name")
}
