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

import com.google.auto.value.AutoValue;
import com.google.cloud.dlp.v2.DlpServiceClient;
import com.google.privacy.dlp.v2.ContentItem;
import com.google.privacy.dlp.v2.DeidentifyConfig;
import com.google.privacy.dlp.v2.DeidentifyContentRequest.Builder;
import com.google.privacy.dlp.v2.DeidentifyContentRequest;
import com.google.privacy.dlp.v2.DeidentifyContentResponse;
import com.google.privacy.dlp.v2.FieldId;
import com.google.privacy.dlp.v2.InspectConfig;
import com.google.privacy.dlp.v2.LocationName;
import com.google.privacy.dlp.v2.Table;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import javax.annotation.Nullable;
import org.apache.beam.sdk.annotations.Experimental;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.transforms.PTransform;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.PCollectionView;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * A {@link PTransform} connecting to Cloud DLP (https://cloud.google.com/dlp/docs/libraries) and
 * inspecting text for identifying data according to provided settings.
 *
 * <p>The transform supports both delimited columnar input data and unstructured input.
 *
 * <p>If the headerColumns property is set and a sideinput with headers is added to the PTransform,
 * delimiter also should be set, else the results will be incorrect. If headerColumns is neither set
 * nor passed as sideinput, input is assumed to be unstructured.
 *
 * <p>Batch size defines how big are batches sent to DLP at once in bytes.
 *
 * <p>The transform consumes {@link KV} of {@link String}s (assumed to be filename as key and
 * contents as value) and outputs {@link KV} of {@link String} (eg. filename) and {@link
 * DeidentifyContentResponse}, which will contain {@link Table} of results for the user to consume.
 *
 * <p>Batch size defines how big are batches sent to DLP at once in bytes.
 *
 * <p>Either deidentifyTemplateName {@link String} or deidentifyConfig {@link DeidentifyConfig} need
 * to be set. inspectConfig {@link InspectConfig} and inspectTemplateName {@link String} are
 * optional.
 *
 * <p>Batch size defines how big are batches sent to DLP at once in bytes.
 */
@Experimental
@SuppressWarnings("serial")
@AutoValue
public abstract class DLPDeidentifyText
    extends PTransform<
        PCollection<KV<String, Table.Row>>, PCollection<KV<String, DeidentifyContentResponse>>> {

  public static final Integer DLP_PAYLOAD_LIMIT_BYTES = 524000;

  /**
   * Deidentify template.
   *
   * @return Template name for data deidentification.
  **/
  @Nullable
  public abstract String getDeidentifyTemplateName();

  /**
   * Deidentify configuration.
   * Prefer using template.
   *
   * @return Configuration object for deidentification. If present, supersedes the template.
  **/
  @Nullable
  public abstract DeidentifyConfig getDeidentifyConfig();

  /**
   * Hold column separator.  Default is ","
   * @return Delimiter to be used when splitting values from input strings into columns.
  **/
  @Nullable
  public abstract Character getColumnDelimiter();

  /**
   * Stores a list of headers for each column.
   *
   * @return List of column names if the input KV value is a delimited row.
  **/
  @Nullable
  public abstract PCollectionView<List<String>> getHeaderColumns();

  /** @return Size of input elements batch to be sent to Cloud DLP service in one request. */
  public abstract Integer getBatchSizeBytes();

  /** @return ID of Google Cloud project to be used when deidentifying data. */
  public abstract String getProjectId();

  /** @return location for DLP region. */
  public abstract String getDlpLocation();

  @AutoValue.Builder
  public abstract static class Builder {

    /**
     * @param deidentifyConfig Configuration object for data deidentification. If present,
     *     supersedes the template settings.
     */
    public abstract DLPDeidentifyText.Builder setDeidentifyConfig(
        DeidentifyConfig deidentifyConfig);

    /** @param deidentifyTemplateName Template name for data deidentification. */
    public abstract DLPDeidentifyText.Builder setDeidentifyTemplateName(
        String deidentifyTemplateName);

    /**
     * @param batchSize Size of input elements batch to be sent to Cloud DLP service in one request.
     */
    public abstract DLPDeidentifyText.Builder setBatchSizeBytes(Integer batchSize);
    /** @param headerColumns List of column names if the input KV value is a delimited row. */
    public abstract DLPDeidentifyText.Builder setHeaderColumns(
        PCollectionView<List<String>> headerColumns);

    /**
     * @param delimiter Delimiter to be used when splitting values from input strings into columns.
     */
    public abstract DLPDeidentifyText.Builder setColumnDelimiter(Character delimiter);

    /** @param projectId ID of Google Cloud project to be used when deidentifying data. */
    public abstract DLPDeidentifyText.Builder setProjectId(String projectId);

    /** @param location for DLP. */
    public abstract DLPDeidentifyText.Builder setDlpLocation(String dlpLocation);

    abstract DLPDeidentifyText autoBuild();

    public DLPDeidentifyText build() {
      DLPDeidentifyText dlpDeidentifyText = autoBuild();
      if (dlpDeidentifyText.getDeidentifyConfig() == null
          && dlpDeidentifyText.getDeidentifyTemplateName() == null) {
        throw new IllegalArgumentException(
            "Either deidentifyConfig or deidentifyTemplateName need to be set!");
      }
      if (dlpDeidentifyText.getBatchSizeBytes() > DLP_PAYLOAD_LIMIT_BYTES) {
        throw new IllegalArgumentException(
            String.format(
                "Batch size is too large! It should be smaller or equal than %d.",
                DLP_PAYLOAD_LIMIT_BYTES));
      }
      if (dlpDeidentifyText.getColumnDelimiter() == null
          && dlpDeidentifyText.getHeaderColumns() != null) {
        throw new IllegalArgumentException(
            "Column delimiter should be set if headers are present.");
      }
      if (dlpDeidentifyText.getHeaderColumns() == null
          && dlpDeidentifyText.getColumnDelimiter() != null) {
        throw new IllegalArgumentException(
            "Column headers should be supplied when delimiter is present.");
      }

      return dlpDeidentifyText;
    }
  }

  public static DLPDeidentifyText.Builder newBuilder() {
    return new AutoValue_DLPDeidentifyText.Builder();
  }

  /**
   * The transform converts the contents of input PCollection into {@link Table.Row}s and then calls
   * Cloud DLP service to perform the deidentification according to provided settings.
   *
   * @param input input PCollection
   * @return PCollection after transformations
   */
  @Override
  public PCollection<KV<String, DeidentifyContentResponse>> expand(
      PCollection<KV<String, Table.Row>> input) {
    return input
        .apply("Batch Contents", ParDo.of(new BatchRequestForDLP(getBatchSizeBytes())))
        .apply(
            "DLPDeidentify",
            ParDo.of(
                    new DLPDeidentifyText.DeidentifyText(
                        getProjectId(),
                        getDlpLocation(),
                        getDeidentifyTemplateName(),
                        getDeidentifyConfig(),
                        getHeaderColumns()))
                .withSideInputs(getHeaderColumns()));
  }

  /** Performs the calls to Cloud DLP service on GCP. */
  static class DeidentifyText
      extends DoFn<KV<String, Iterable<Table.Row>>, KV<String, DeidentifyContentResponse>> {

    public static final Logger LOG = LoggerFactory.getLogger(DeidentifyText.class);
    private final String projectId;
    private final String dlpLocation;
    private final String deidentifyTemplateName;
    private final DeidentifyConfig deidentifyConfig;
    private final PCollectionView<List<String>> headerColumns;
    private transient DeidentifyContentRequest.Builder requestBuilder;
    private transient DlpServiceClient dlpServiceClient;

    @Setup
    public void setup() throws IOException {
      requestBuilder = DeidentifyContentRequest.newBuilder().setParent(LocationName.of(this.projectId,this.dlpLocation).toString());
      LOG.debug("DLP location {}", LocationName.of(this.projectId,this.dlpLocation).toString());

      if (deidentifyConfig != null) {
        requestBuilder.setDeidentifyConfig(deidentifyConfig);
      }
      if (deidentifyTemplateName != null) {
        requestBuilder.setDeidentifyTemplateName(deidentifyTemplateName);
      }
      dlpServiceClient = DlpServiceClient.create();
    }

    @Teardown
    public void teardown() {
      dlpServiceClient.close();
    }

    /**
     * Send text to DLP for deidentification.
     *
     * @param projectId ID of GCP project that should be used for deidentification.
     * @param inspectTemplateName Template name for inspection. Optional.
     * @param deidentifyTemplateName Template name for deidentification. Either this or
     *     deidentifyConfig is required.
     * @param inspectConfig Configuration object for inspection. Optional.
     * @param deidentifyConfig Reidentification config containing data transformations. Either this
     *     or deidentifyTemplateName is required.
     * @param headerColumns Header row of the table if applicable.
     */
    public DeidentifyText(
        String projectId,
        String dlpLocation,
        String deidentifyTemplateName,
        DeidentifyConfig deidentifyConfig,
        PCollectionView<List<String>> headerColumns) {
      this.projectId = projectId;
      this.dlpLocation = dlpLocation;
      this.deidentifyTemplateName = deidentifyTemplateName;
      this.deidentifyConfig = deidentifyConfig;
      this.headerColumns = headerColumns;
    }

    @ProcessElement
    public void processElement(ProcessContext context) throws IOException {
      List<FieldId> tableHeaders;
      if (headerColumns != null) {
        tableHeaders =
            context.sideInput(headerColumns).stream()
                .map(header -> FieldId.newBuilder().setName(header).build())
                .collect(Collectors.toList());
      } else {
        // handle unstructured input.
        tableHeaders = new ArrayList<>();
        tableHeaders.add(FieldId.newBuilder().setName("value").build());
      }
      Table table =
          Table.newBuilder()
              .addAllHeaders(tableHeaders)
              .addAllRows(context.element().getValue())
              .build();
      ContentItem contentItem = ContentItem.newBuilder().setTable(table).build();
      this.requestBuilder.setItem(contentItem);
      DeidentifyContentResponse response =
          dlpServiceClient.deidentifyContent(requestBuilder.build());
      context.output(KV.of(context.element().getKey(), response));
    }
  }
}
