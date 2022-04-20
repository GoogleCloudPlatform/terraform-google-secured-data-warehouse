package standalone_bucket

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/stretchr/testify/assert"
)

func TestTemp(t *testing.T) {
	bucketName := "example_bucket_prj_feature_standalone"
	projectID := "prj-feature-standalone"
	gcloudArgs := gcloud.WithCommonArgs([]string{"--project", projectID, "--json"})

	op := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", bucketName), gcloudArgs).Array()[0]
	assert.Equal(t, fmt.Sprintf("example_bucket_prj_feature_standalone"), op.Get("metadata.name").String(), "has expected name ")
}

