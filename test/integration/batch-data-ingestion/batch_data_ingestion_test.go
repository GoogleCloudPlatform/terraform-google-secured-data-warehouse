// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package batch_data_ingestion

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
	"github.com/tidwall/gjson"
)

func TestBatchDataIngestion(t *testing.T) {
	bdi := tft.NewTFBlueprintTest(t)
	bdi.DefineVerify(func(assert *assert.Assertions) {
		bdi.DefaultVerify(assert)

		projectID := bdi.GetStringOutput("project_id")
		gcOpts := gcloud.WithCommonArgs([]string{"--project", projectID, "--format", "json"})

		scheduler := gcloud.Run(t, fmt.Sprintf("scheduler jobs describe %s", bdi.GetStringOutput("scheduler_id")), gcOpts)
		assert.Equal("ENABLED", scheduler.Get("state").String(), "should have current state ENABLED")
		assert.NotEmpty(scheduler.Get("httpTarget").String(), "should have httpTarget not empty")

		// alpha command to list buckets has --json instead of format=json
		bucket := gcloud.Run(t, "alpha storage ls", gcloud.WithCommonArgs([]string{"--buckets", fmt.Sprintf("gs://%s", bdi.GetStringOutput("dataflow_temp_bucket_name")), "--json", "--project", projectID}))
		assert.Equal(1, len(bucket.Array()), "only one matching bucket exists")

		fwTypes := map[string]string{"INGRESS": "i", "EGRESS": "e"}
		for fwType, s := range fwTypes {
			ingressFWName := fmt.Sprintf("fw-e-shared-private-0-%s-a-dataflow-tcp-12345-12346", s)
			fw := gcloud.Run(t, fmt.Sprintf("compute firewall-rules describe %s", ingressFWName), gcOpts)
			assert.Equal(fwType, fw.Get("direction").String(), fmt.Sprintf("direction is %s", fwType))

			fwPortProtocol := fw.Get("allowed").Array()[0]
			assert.Equal("tcp", fwPortProtocol.Get("IPProtocol").String(), "has tcp IPProtocol")

			fwAllowedPorts := fwPortProtocol.Get("ports").Array()
			expectedAllowedPorts := []string{"12345", "12346"}
			assert.ElementsMatch(expectedAllowedPorts, getResultStrSlice(fwAllowedPorts), "has only allowed ports")

			if fwType == "INGRESS" {
				assert.Equal(1, len(fw.Get("sourceRanges").Array()), "only one source range")
				assert.Equal("10.0.32.0/21", fw.Get("sourceRanges").Array()[0].String(), "sourceRange is 10.0.32.0/21")
			}
		}
	})

	bdi.Test()
}

// getResultStrSlice parses results into a string slice
func getResultStrSlice(rs []gjson.Result) []string {
	s := make([]string, 0)
	for _, r := range rs {
		s = append(s, r.String())
	}
	return s
}
