package standalone_projects

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/stretchr/testify/assert"
)

func TestTemp(t *testing.T) {
	dataGovprojectID := "prj-feature-standalone"
	dataIngprojectID := "prj-feature-standalone"
	nonConfprojectID := "prj-feature-standalone"
	ConfprojectID := "prj-feature-standalone"

	gcloudArgs := gcloud.WithCommonArgs([]string{"--format", "json"})

	opdataGov := gcloud.Run(t, fmt.Sprintf("projects describe %s", dataGovprojectID), gcloudArgs)
	assert.Equal(t, fmt.Sprintf("prj-feature-standalone"), opdataGov.Get("projectId").String(), "should have expected projectID ")

	opdataIng := gcloud.Run(t, fmt.Sprintf("projects describe %s", dataIngprojectID), gcloudArgs)
	assert.Equal(t, fmt.Sprintf("prj-feature-standalone"), opdataIng.Get("projectId").String(), "should have expected projectID ")

	opnonConf := gcloud.Run(t, fmt.Sprintf("projects describe %s", nonConfprojectID), gcloudArgs)
	assert.Equal(t, fmt.Sprintf("prj-feature-standalone"), opnonConf.Get("projectId").String(), "should have expected projectID ")

	opConf := gcloud.Run(t, fmt.Sprintf("projects describe %s", ConfprojectID), gcloudArgs)
	assert.Equal(t, fmt.Sprintf("prj-feature-standalone"), opConf.Get("projectId").String(), "should have expected projectID ")
}

