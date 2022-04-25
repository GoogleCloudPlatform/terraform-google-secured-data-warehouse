package standalone_projects

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestStandaloneProjects(t *testing.T) {
	projects := tft.NewTFBlueprintTest(t)

	projects.DefineVerify(func(assert *assert.Assertions) {
		projects.DefaultVerify(assert)

		dataGovprojectID := projects.GetStringOutput("data_governance_project_id")
		dataIngprojectID := projects.GetStringOutput("data_ingestion_project_id")
		nonConfprojectID := projects.GetStringOutput("non_confidential_data_project_id")
		ConfprojectID := projects.GetStringOutput("confidential_data_project_id")

		gcloudArgs := gcloud.WithCommonArgs([]string{"--format", "json"})

		opdataGov := gcloud.Run(t, fmt.Sprintf("projects describe %s", dataGovprojectID), gcloudArgs)
		assert.Equal(t, fmt.Sprintf("data_governance_standalone"), opdataGov.Get("projectId").String(), "should have expected projectID ")

		opdataIng := gcloud.Run(t, fmt.Sprintf("projects describe %s", dataIngprojectID), gcloudArgs)
		assert.Equal(t, fmt.Sprintf("data_ingestion_standalone"), opdataIng.Get("projectId").String(), "should have expected projectID ")

		opnonConf := gcloud.Run(t, fmt.Sprintf("projects describe %s", nonConfprojectID), gcloudArgs)
		assert.Equal(t, fmt.Sprintf("non_confidential_data_standalone"), opnonConf.Get("projectId").String(), "should have expected projectID ")

		opConf := gcloud.Run(t, fmt.Sprintf("projects describe %s", ConfprojectID), gcloudArgs)
		assert.Equal(t, fmt.Sprintf("confidential_data_standalone"), opConf.Get("projectId").String(), "should have expected projectID ")
	})

	projects.Test()
}
