package standalone_pubsub

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestStandalonePubsub(t *testing.T) {
	pubsub := tft.NewTFBlueprintTest(t)

	pubsub.DefineVerify(func(assert *assert.Assertions) {
		pubsub.DefaultVerify(assert)

		projectId := pubsub.GetStringOutput("project_id")

		op := gcloud.Run(t, fmt.Sprintf("pubsub topics describe tpc-data-ingestion-topic --project=%s", projectId))
		assert.Equal(t, fmt.Sprintf("projects/%s/topics/tpc-data-ingestion-topic", projectId), op.Get("name").String(), "has expected name")
	})

	pubsub.Test()
}
