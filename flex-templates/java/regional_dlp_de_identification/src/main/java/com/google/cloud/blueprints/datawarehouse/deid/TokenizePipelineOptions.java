/*
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.cloud.blueprints.datawarehouse.deid;

import org.apache.beam.runners.dataflow.options.DataflowPipelineOptions;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.Validation.Required;
import org.apache.beam.sdk.options.ValueProvider;

/**
 * The {@link TokenizePipelineOptions} interface provides the custom execution
 * options passed by the executor at the command-line.
 */
public interface TokenizePipelineOptions extends DataflowPipelineOptions {

    @Description("The file pattern to read records from (e.g. gs://bucket/file-*.csv)")
    @Required
    ValueProvider<String> getInputFilePattern();

    void setInputFilePattern(ValueProvider<String> value);

    @Description("Output BigQuery Table to hold de-identified data; specified as "
        + "<project_id>:<dataset_id>.<table_id>. ")
    @Required
    String getOutputBigQueryTable();

    void setOutputBigQueryTable(String value);

    @Description("DLP Deidentify Template to be used for API request "
        + "(e.g.projects/{project_id}/deidentifyTemplates/{deIdTemplateId}")
    @Required
    ValueProvider<String> getDeidentifyTemplateName();

    void setDeidentifyTemplateName(ValueProvider<String> value);

    @Description("DLP API has a limit for payload size of 524KB /api call. "
        + "That's why dataflow process will need to chunk it. User will have to decide "
        + "on how they would like to batch the request depending on number of rows "
        + "and how big each row is.")
    @Required
    ValueProvider<Integer> getBatchSize();

    void setBatchSize(ValueProvider<Integer> value);

    @Description("Project id to be used for Big Query output")
    @Required
    ValueProvider<String> getBqProjectId();

    void setBqProjectId(ValueProvider<String> value);

    @Description("Big Query data set must exist before the pipeline runs (e.g. pii-dataset")
    @Required
    ValueProvider<String> getDatasetName();

    void setDatasetName(ValueProvider<String> value);

    @Description("Project id to be used for DLP Tokenization")
    @Required
    ValueProvider<String> getDlpProjectId();

    void setDlpProjectId(ValueProvider<String> value);

    @Description("Location to be used for DLP Tokenization")
    @Required
    ValueProvider<String> getDlpLocation();

    void setDlpLocation(ValueProvider<String> value);

    @Description("Triggering Frequency which file writes are triggered in seconds")
    @Required
    ValueProvider<Integer> getTrigFrequency();

    void setTrigFrequency(ValueProvider<Integer> value);
}
