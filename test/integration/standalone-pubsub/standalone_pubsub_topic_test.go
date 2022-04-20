package standalone_pubsub_topic

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/stretchr/testify/assert"
)

func TestTemp(t *testing.T) {
	projectId := "prj-feature-standalone"

	op := gcloud.Run(t, fmt.Sprintf("pubsub topics describe tpc-data-ingestion-337d2ece --project=%s", projectId))
	assert.Equal(t, fmt.Sprintf("projects/%s/topics/tpc-data-ingestion-337d2ece", projectId), op.Get("name").String(), "has expected name")
}

