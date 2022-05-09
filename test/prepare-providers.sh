#!/usr/bin/env bash

# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Note:
# The test/fixture/standalone requires a provider.tf to run. As we already have a provider.tf in examples/standalone, we will hit in a loop and then in an error when the test is being executed.
# As a workaround, this script is being used to disable the provider.tf from examples/standalone when the Go test is being executed for Standalone.

config1="examples/standalone/providers.tf"
config2="test/fixtures/standalone/providers.tf"
if cmp -s "$config1" "$config2"; then
    echo "${config1} and ${config2} are the same"
    mv examples/standalone/providers.tf examples/standalone/providers.tf.disabled
else
    echo "${config1} and ${config2} differ"
    cat examples/standalone/providers.tf > test/fixtures/standalone/providers.tf
    mv examples/standalone/providers.tf examples/standalone/providers.tf.disabled
fi
