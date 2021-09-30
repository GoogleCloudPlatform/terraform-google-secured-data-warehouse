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
)

func TestBatchDataIngestion(t *testing.T) {
	bdi := tft.NewTFBlueprintTest(t)
	bdi.DefineVerify(func(assert *assert.Assertions) {
		bdi.DefaultVerify(assert)

		projectID := bdi.GetStringOutput("project_id")
		scheduler := gcloud.Run(t, fmt.Sprintf("scheduler jobs describe %s --project %s", bdi.GetStringOutput("scheduler_id"), projectID))
		assert.Equal("ENABLED", scheduler.Get("state").String(), "should have current state ENABLED")
		assert.NotEmpty(scheduler.Get("httpTarget").String(), "should have httpTarget not empty")

		// alpha command to list buckets has --json instead of format=json
		bucket := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s --project %s", bdi.GetStringOutput("dataflow_temp_bucket_name"), projectID), gcloud.WithCommonArgs([]string{"--json"}))
		assert.Equal(1, len(bucket.Array()), "only one matching bucket exists")

		fwTypes := map[string]string{"INGRESS": "i", "EGRESS": "e"}
		for fwType, s := range fwTypes {
			ingressFWName := fmt.Sprintf("fw-e-shared-private-0-%s-a-dataflow-tcp-12345-12346", s)
			fw := gcloud.Run(t, fmt.Sprintf("compute firewall-rules describe %s --project %s", ingressFWName, projectID))
			assert.Equal(fwType, fw.Get("direction").String(), fmt.Sprintf("direction is %s", fwType))

			fwAllowedPorts := fw.Get("allowed").Array()[0].Get("ports").Array()
			assert.Equal(2, len(fwAllowedPorts), "only two ports are allowed")
			assert.Equal("tcp", fw.Get("allowed").Array()[0].Get("IPProtocol").String(), "has tcp IPProtocol")
			expectedAllowedPorts := []string{"12345", "12346"}
			for _, fwp := range fwAllowedPorts {
				assert.Contains(expectedAllowedPorts, fwp.String(), fmt.Sprintf("allowed ports in %s", expectedAllowedPorts))
			}

			if fwType == "INGRESS" {
				assert.Equal(1, len(fw.Get("sourceRanges").Array()), "only one source range")
				assert.Equal("10.0.32.0/21", fw.Get("sourceRanges").Array()[0].String(), "sourceRange is 10.0.32.0/21")
			}
		}
	})

	bdi.Test()
}
