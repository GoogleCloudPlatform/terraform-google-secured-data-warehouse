/*
 * Copyright 2021 Google LLC
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

package com.google.cloud.blueprints.datawarehouse;

import org.apache.beam.runners.dataflow.options.DataflowPipelineOptions;
import org.apache.beam.sdk.options.Default;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.Validation.Required;

/**
 * The {@link BigQueryJobPipelineOptions} interface provides the custom execution options
 * passed by the executor at the command-line.
 */
public interface BigQueryTransformPipelineOptions extends DataflowPipelineOptions {

  @Description("Input BigQuery Table with de-identified data from DLP or data to re-identify; "
      + "specified as <project_id>:<dataset_id>.<table_id>. "
      + "The dataset_id must already exist")
  @Required
  String getInputBigQueryTable();

  void setInputBigQueryTable(String value);

  @Description("Output BigQuery Dataset to hold re-identified data; specified as "
      + "<project_id>:<dataset_id>.<table_id>. ")
  @Required
  String getOutputBigQueryDataset();

  void setOutputBigQueryDataset(String value);

  @Description("DLP Deidentify Template to be used for API request. "
        + "Should match the de-identification table used to de-id the input table. "
        + "(e.g.projects/{project_id}/deidentifyTemplates/{deIdTemplateId}")
  @Required
  String getDeidentifyTemplateName();

  void setDeidentifyTemplateName(String value);

  @Description("Confidential data project id to be used for Big Query output")
  @Required
  String getConfidentialDataProjectId();

  void setConfidentialDataProjectId(String value);

  @Description("Project id to be used for DLP Tokenization")
  @Required
  String getDlpProjectId();

  void setDlpProjectId(String value);

  @Description("Location to be used for DLP Tokenization")
  String getDlpLocation();

  void setDlpLocation(String value);

  @Description("Parameter to choose between De-Identify or Re-Identify data")
  @Required
  String getDlpTransform();

  void setDlpTransform(String value);

  @Description("DLP API has a limit for payload size of 524KB /api call. "
  + "That's why dataflow process will need to chunk it. User will have to decide "
  + "on how they would like to batch the request depending on number of rows "
  + "and how big each row is.")
  @Default.Integer(100)
  Integer getBatchSize();

  void setBatchSize(Integer value);

  @Description("Column delimiter")
  @Default.Character(',')
  Character getColumnDelimiter();

  void setColumnDelimiter(Character value);
}
