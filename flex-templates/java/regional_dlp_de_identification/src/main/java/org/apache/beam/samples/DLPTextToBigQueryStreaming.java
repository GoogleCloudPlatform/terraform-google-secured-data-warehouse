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

package org.apache.beam.samples;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import com.google.api.services.bigquery.model.TableRow;

import org.apache.beam.runners.dataflow.options.DataflowPipelineOptions;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.PipelineResult;
import org.apache.beam.sdk.coders.KvCoder;
import org.apache.beam.sdk.coders.StringUtf8Coder;
import org.apache.beam.sdk.io.Compression;
import org.apache.beam.sdk.io.FileIO;
import org.apache.beam.sdk.io.FileIO.ReadableFile;
import org.apache.beam.sdk.io.ReadableFileCoder;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.options.Validation.Required;
import org.apache.beam.sdk.options.ValueProvider;
import org.apache.beam.sdk.options.ValueProvider.NestedValueProvider;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.GroupByKey;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.transforms.View;
import org.apache.beam.sdk.transforms.Watch;
import org.apache.beam.sdk.transforms.WithKeys;
import org.apache.beam.sdk.transforms.windowing.AfterProcessingTime;
import org.apache.beam.sdk.transforms.windowing.FixedWindows;
import org.apache.beam.sdk.transforms.windowing.GlobalWindows;
import org.apache.beam.sdk.transforms.windowing.Repeatedly;
import org.apache.beam.sdk.transforms.windowing.Window;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.PCollectionView;
import org.joda.time.Duration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


/**
 * The {@link DLPTextToBigQueryStreaming} is a streaming pipeline that reads CSV
 * files from a storage location (e.g. Google Cloud Storage), uses Cloud DLP API
 * to inspect, classify, and mask sensitive information (e.g. PII Data like
 * passport or SIN number) and at the end stores obfuscated data in BigQuery
 * (Dynamic Table Creation) to be used for various purposes. e.g. data analytics,
 * ML model. Cloud DLP inspection and masking can be configured by the user and
 * can make use of over 90 built in detectors and masking techniques like
 * tokenization, secure hashing, date shifting, partial masking, and more.
 *
 * <p>
 * <b>Pipeline Requirements</b>
 *
 * <ul>
 * <li>DLP Templates exist (e.g. deidentifyTemplate, InspectTemplate)
 * <li>The BigQuery Dataset exists
 * </ul>
 *
 * <p>
 * <b>Example Usage</b>
 *
 * <pre>
 * # Set the pipeline vars
 * PROJECT_ID=PROJECT ID HERE
 * BUCKET_NAME=BUCKET NAME HERE
 * PIPELINE_FOLDER=gs://${BUCKET_NAME}/dataflow/pipelines/dlp-text-to-bigquery
 *
 * # Set the runner
 * RUNNER=DataflowRunner
 *
 * # Build the template
 * mvn compile exec:java \
 * -Dexec.mainClass=com.google.cloud.teleport.templates.DLPTextToBigQueryStreaming \
 * -Dexec.cleanupDaemonThreads=false \
 * -Dexec.args=" \
 * --project=${PROJECT_ID} \
 * --stagingLocation=${PIPELINE_FOLDER}/staging \
 * --tempLocation=${PIPELINE_FOLDER}/temp \
 * --templateLocation=${PIPELINE_FOLDER}/template \
 * --runner=${RUNNER}"
 *
 * # Execute the template
 * JOB_NAME=dlp-text-to-bigquery-$USER-`date +"%Y%m%d-%H%M%S%z"`
 *
 * gcloud dataflow jobs run ${JOB_NAME} \
 * --gcs-location=${PIPELINE_FOLDER}/template \
 * --zone=us-east1-d \
 * --parameters \
 * "inputFilePattern=gs://<bucketName>/<fileName>.csv, batchSize=15,
 *  datasetName=<BQDatasetId>, bqProjectId=<BQProjectId>,
 *  dlpProjectId=<DLPProjectId>, dlpLocation=<DLPLocation>,
 *  deidentifyTemplateName=projects/{projectId}/deidentifyTemplates/{deIdTemplateId}
 * </pre>
 */
public class DLPTextToBigQueryStreaming {

  public static final Logger LOG = LoggerFactory.getLogger(DLPTextToBigQueryStreaming.class);
  /** Default interval for polling files in GCS. */
  private static final Duration DEFAULT_POLL_INTERVAL = Duration.standardSeconds(30);
  /** Default batch size if value not provided in execution. */
  private static final Integer DEFAULT_BATCH_SIZE = 100;
  /** Default window interval to create side inputs for header records. */
  private static final Duration WINDOW_INTERVAL = Duration.standardSeconds(30);

  /**
   * Main entry point for executing the pipeline. This will run the pipeline
   * asynchronously. If blocking execution is required, use the {@link
   * DLPTextToBigQueryStreaming#run(TokenizePipelineOptions)} method to start the
   * pipeline and invoke {@code result.waitUntilFinish()} on the {@link
   * PipelineResult}
   *
   * @param args The command-line arguments to the pipeline.
   */
  public static void main(String[] args) {

    TokenizePipelineOptions options = PipelineOptionsFactory.fromArgs(args).withValidation()
        .as(TokenizePipelineOptions.class);
    run(options);
  }

  /**
   * Runs the pipeline with the supplied options.
   *
   * @param options The execution parameters to the pipeline.
   * @return The result of the pipeline execution.
   */
  public static PipelineResult run(TokenizePipelineOptions options) {
    // Create the pipeline
    Pipeline p = Pipeline.create(options);
    /*
     * Steps:
     * 1) Read from the text source continuously based on default interval e.g. 30
     * seconds
     * - Setup a window for 30 secs to capture the list of files emitted.
     * - Group by file name as key and ReadableFile as a value.
     * 2) Create a side input for the window containing list of headers par file.
     * 3) Create the BigQuery schema from file headers
     * 4) Output each readable file for content processing.
     * 5) Split file contents based on batch size for parallel processing.
     * 6) Process each split as a DLP table content request to invoke API.
     * 7) Convert DLP Table Rows to BQ Table Row.
     * 8) Create dynamic table and insert successfully converted records into BQ.
     */

    PCollection<KV<String, Iterable<ReadableFile>>> csvFiles = p
        /*
         * 1) Read from the text source continuously based on default interval e.g. 300
         * seconds
         * - Setup a window for 30 secs to capture the list of files emitted.
         * - Group by file name as key and ReadableFile as a value.
         */
        .apply(
            "Poll Input Files",
            FileIO.match()
                .filepattern(options.getInputFilePattern())
                .continuously(DEFAULT_POLL_INTERVAL, Watch.Growth.never()))
        .apply("Find Pattern Match", FileIO.readMatches().withCompression(Compression.AUTO))
        .apply("Add File Name as Key", WithKeys.of(file -> Util.getAndValidateFileAttributes(file)))
        .setCoder(KvCoder.of(StringUtf8Coder.of(), ReadableFileCoder.of()))
        .apply(
            "Fixed Window(30 Sec)",
            Window.<KV<String, ReadableFile>>into(FixedWindows.of(WINDOW_INTERVAL))
                .triggering(
                    Repeatedly.forever(
                        AfterProcessingTime.pastFirstElementInPane()
                            .plusDelayOf(Duration.ZERO)))
                .discardingFiredPanes()
                .withAllowedLateness(Duration.ZERO))
        .apply(GroupByKey.create());

    /*
     * Side input for the window to capture list of headers for each file emitted so
     * that it can be used in the next transform.
     */
    PCollectionView<List<KV<String, List<String>>>> headerMap = csvFiles

        // 2) Create a side input for the window containing list of headers par file.
        .apply(
            "Create Header Map",
            ParDo.of(
                new DoFn<KV<String, Iterable<ReadableFile>>, KV<String, List<String>>>() {

                  @ProcessElement
                  public void processElement(ProcessContext c) {
                    String fileKey = c.element().getKey();
                    c.element()
                        .getValue()
                        .forEach(
                            file -> {
                              try (BufferedReader br = Util.getReader(file)) {
                                c.output(KV.of(fileKey, Util.getFileHeaders(br)));

                              } catch (IOException e) {
                                LOG.error("Failed to Read File {}", e.getMessage());
                                throw new RuntimeException(e);
                              }
                            });
                  }
                }))
        .apply("View As List", View.asList());

    PCollectionView<Map<String, String>> schemaView = csvFiles

        // 3) Create the BigQuery schema from file headers
        .apply(
            "Create Schema",
            ParDo.of(
                new GenerateTableSchema(options.getOutputBigQueryTable())))
        .apply("To Global Window", Window.into(new GlobalWindows()))
        .apply("ViewSchemaAsMap", View.asMap());

    PCollection<KV<String, TableRow>> bqDataMap = csvFiles

        // 4) Output each readable file for content processing.
        .apply(
            "File Handler",
            ParDo.of(
                new DoFn<KV<String, Iterable<ReadableFile>>, KV<String, ReadableFile>>() {
                  @ProcessElement
                  public void processElement(ProcessContext c) {
                    String fileKey = c.element().getKey();
                    c.element()
                        .getValue()
                        .forEach(
                            file -> {
                              c.output(KV.of(fileKey, file));
                            });
                  }
                }))

        // 5) Split file contents based on batch size for parallel processing.
        .apply(
            "Process File Contents",
            ParDo.of(
                new CSVReader(
                    NestedValueProvider.of(
                        options.getBatchSize(),
                        batchSize -> {
                          if (batchSize != null) {
                            return batchSize;
                          } else {
                            return DEFAULT_BATCH_SIZE;
                          }
                        }),
                    headerMap))
                .withSideInputs(headerMap))

        // 6) Create a DLP Table content request and invoke DLP API for each processing
        .apply(
            "DLP-Tokenization",
            ParDo.of(
                new DLPTokenizationDoFn(
                    options.getDlpProjectId(),
                    options.getDlpLocation(),
                    options.getDeidentifyTemplateName())))

        // 7) Convert DLP Table Rows to BQ Table Row
        .apply(
            "Process Tokenized Data",
            ParDo.of(
                new TableRowProcessorDoFn()));

    // 8) Create dynamic table and insert successfully converted records into BQ.
    bqDataMap.apply(
        "Write To BQ",
        BigQueryIO.<KV<String, TableRow>>write()
            .to(options.getOutputBigQueryTable())
            .withSchemaFromView(schemaView)
            .withFormatFunction(
                element -> {
                  return element.getValue();
                })
            .withWriteDisposition(BigQueryIO.Write.WriteDisposition.WRITE_APPEND)
            .withMethod(BigQueryIO.Write.Method.FILE_LOADS)
            .withTriggeringFrequency(Duration.standardSeconds(options.getTrigFrequency().get()))
            .withCreateDisposition(BigQueryIO.Write.CreateDisposition.CREATE_IF_NEEDED)
            .withoutValidation()
            .withAutoSharding());

    return p.run();
  }

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
}
