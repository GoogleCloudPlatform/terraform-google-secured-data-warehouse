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

import com.google.api.services.bigquery.model.TableRow;
import java.util.List;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.PipelineResult;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.transforms.GroupByKey;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.transforms.View;
import org.apache.beam.sdk.transforms.windowing.AfterProcessingTime;
import org.apache.beam.sdk.transforms.windowing.GlobalWindows;
import org.apache.beam.sdk.transforms.windowing.Repeatedly;
import org.apache.beam.sdk.transforms.windowing.Window;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.PCollectionView;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * The {@link BigQueryDLPBigQuery} is a streaming pipeline that reads BigQuery
 * tables, uses Cloud DLP API to inspect and classify sensitive information (e.g. PII Data like
 * passport or SIN number) and at the end stores tags in Data Catalog to be used for various
 * purposes.
 */
public class BigQueryDLPBigQuery {
  public static final String DLP_REIDENTIFY_TRANSFORMATION = "RE-IDENTIFY";
  private static final String PIPELINE_PACKAGE_NAME = "com.google.cloud.blueprints.datawarehouse";
  public static final Logger LOG = LoggerFactory.getLogger(BigQueryDLPBigQuery.class);

  /**
   * Main entry point for executing the pipeline. This will run the pipeline asynchronously. If
   * blocking execution is required, use the {@link
   * DLP2DatacatalogTagsAllBigQueryInspection method to start the
   * pipeline and invoke {@code result.waitUntilFinish()} on the {@link PipelineResult}
   *
   * @param args The command-line arguments to the pipeline.
   *
  **/
  public static void main(String[] args) {

    BigQueryTransformPipelineOptions options =
        PipelineOptionsFactory.fromArgs(args)
            .as(BigQueryTransformPipelineOptions.class);

    run(options);
  }

  /**
   * Runs the pipeline with the supplied options.
   * https://github.com/GoogleCloudPlatform/dlp-dataflow-deidentification/blob/2375b8af9017a32a836ae09a43b3e498a5db63f1/src/main/java/com/google/swarm/tokenization/DLPTextToBigQueryStreamingV2.java#L204
   *
   * @param options The execution parameters to the pipeline.
   * @return The result of the pipeline execution.
   */
  public static PipelineResult run(BigQueryTransformPipelineOptions options) {
    // Create the pipeline
    Pipeline p = Pipeline.create(options);

    /*
    *  Steps:
    *    1) Read record from input BQ table
    *    2) get header
    *    3) convert to DLP
    *    4) re-identify with DLP
    *    5) convert to BQ tablerow
    *    6) write re-identity data to output BQ table
    */

    PCollection<KV<String, TableRow>> record =
        p.apply(
          "ReadFromBQ",
          BigQueryReadTransform.newBuilder()
            .setTableRef(options.getInputBigQueryTable())
            .build());

    PCollectionView<List<String>> selectedColumns =
        record.apply(
          "GlobalWindow",
          Window.<KV<String, TableRow>>into(new GlobalWindows())
            .triggering(
                Repeatedly.forever(AfterProcessingTime.pastFirstElementInPane()))
            .discardingFiredPanes()
        )
        .apply(
          "GroupByTableName",
          GroupByKey.create()
        )
        .apply(
          "GetHeader",
          ParDo.of(new BigQueryTableHeaderDoFn())
        )
        .apply(
          "ViewAsList",
          View.asList()
        );

    PCollection<KV<String, TableRow>> transformData =

         record.apply(
          "ConvertTableRow",
          ParDo.of(new MergeBigQueryRowToDlpRow())
        )
        .apply(
          "DLPTransform",
          (
            ( options.getDlpTransform().equals(DLP_REIDENTIFY_TRANSFORMATION)) ? (
          DLPReidentifyTransform.newBuilder()
            .setBatchSize(options.getBatchSize())
            .setDeidTemplateName(options.getDeidentifyTemplateName())
            .setProjectId(options.getDlpProjectId())
            .setDlpLocation(options.getDlpLocation())
            .setHeader(selectedColumns)
            .setColumnDelimiter(options.getColumnDelimiter())
            .build() ) : (
          DLPDeidentifyTransform.newBuilder()
            .setBatchSize(options.getBatchSize())
            .setDeidTemplateName(options.getDeidentifyTemplateName())
            .setProjectId(options.getDlpProjectId())
            .setDlpLocation(options.getDlpLocation())
            .setHeader(selectedColumns)
            .setColumnDelimiter(options.getColumnDelimiter())
            .build() )
          )
        )
        .get(Util.jobSuccess);



    // BQ insert
    transformData.apply(
        "BigQueryInsert",
        BigQueryDynamicWriteTransform.newBuilder()
          .setDatasetId(options.getOutputBigQueryDataset())
          .setProjectId(options.getProject())
          .build()
    );

    return p.run();
  }

}
