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
import com.google.auto.value.AutoValue;
import com.google.privacy.dlp.v2.DeidentifyContentResponse;
import com.google.privacy.dlp.v2.Table;
import java.util.List;
import java.util.stream.Collectors;
import javax.annotation.Nullable;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryHelpers;
import org.apache.beam.sdk.metrics.Counter;
import org.apache.beam.sdk.metrics.Metrics;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.PTransform;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.PCollectionTuple;
import org.apache.beam.sdk.values.PCollectionView;
import org.apache.beam.sdk.values.TupleTagList;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


@SuppressWarnings("serial")
@AutoValue
public abstract class DLPDeidentifyTransform
    extends PTransform<PCollection<KV<String, Table.Row>>, PCollectionTuple> {
  public static final Logger LOG = LoggerFactory.getLogger(DLPDeidentifyTransform.class);

  @Nullable
  public abstract String deidTemplateName();

  public abstract Integer batchSize();

  public abstract String projectId();

  public abstract String dlpLocation();

  public abstract Character columnDelimiter();

  public abstract PCollectionView<List<String>> header();


  @AutoValue.Builder
  public abstract static class Builder {

    public abstract Builder setDeidTemplateName(String inspectTemplateName);

    public abstract Builder setBatchSize(Integer batchSize);

    public abstract Builder setProjectId(String projectId);

    public abstract Builder setDlpLocation(String dlpLocation);

    public abstract Builder setHeader(PCollectionView<List<String>> header);

    public abstract Builder setColumnDelimiter(Character columnDelimiter);

    public abstract DLPDeidentifyTransform build();
  }

  public static Builder newBuilder() {
    return new AutoValue_DLPDeidentifyTransform.Builder();
  }


  @Override
  public PCollectionTuple expand(PCollection<KV<String, Table.Row>> input) {
      return input
          .apply(
              "DeIdTransform",
              DLPDeidentifyText.newBuilder()
                  .setBatchSizeBytes(batchSize())
                  .setColumnDelimiter(columnDelimiter())
                  .setHeaderColumns(header())
                  .setDeidentifyTemplateName(deidTemplateName())
                  .setProjectId(projectId())
                  .setDlpLocation(dlpLocation())
                  .build())
          .apply(
              "ConvertDeidResponse",
              ParDo.of(new ConvertDeidResponse())
                  .withOutputTags(Util.jobSuccess, TupleTagList.of(Util.jobFailure)));
    }

  static class ConvertDeidResponse
      extends DoFn<KV<String, DeidentifyContentResponse>, KV<String, TableRow>> {

    private final Counter numberOfBytesDeidentified =
        Metrics.counter(ConvertDeidResponse.class, "NumberOfBytesDeidentified");

    @ProcessElement
    public void processElement(
        @Element KV<String, DeidentifyContentResponse> element, MultiOutputReceiver out) {

      String deidTableName = BigQueryHelpers.parseTableSpec(element.getKey()).getTableId();
      String tableName = String.format("%s_%s", deidTableName, Util.BQ_DEID_TABLE_EXT);
      LOG.info("Table Ref {}", tableName);

      Table originalData = element.getValue().getItem().getTable();
      numberOfBytesDeidentified.inc(originalData.toByteArray().length);
      List<String> headers =
          originalData.getHeadersList().stream()
              .map(fid -> fid.getName())
              .collect(Collectors.toList());
      List<Table.Row> outputRows = originalData.getRowsList();
      if (outputRows.size() > 0) {
        for (Table.Row outputRow : outputRows) {
          if (outputRow.getValuesCount() != headers.size()) {
            throw new IllegalArgumentException(
                "BigQuery column count must exactly match with data element count");
          }
          out.get(Util.jobSuccess)
              .output(
                  KV.of(
                      tableName,
                      Util.createBqRow(outputRow, headers.toArray(new String[headers.size()]))));
        }
      }
    }
  }
}
