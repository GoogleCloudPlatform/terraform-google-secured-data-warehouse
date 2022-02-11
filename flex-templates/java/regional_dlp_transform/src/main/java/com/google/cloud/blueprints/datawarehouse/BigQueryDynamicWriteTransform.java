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

import com.google.api.services.bigquery.model.TableCell;
import com.google.api.services.bigquery.model.TableFieldSchema;
import com.google.api.services.bigquery.model.TableRow;
import com.google.api.services.bigquery.model.TableSchema;
import com.google.auto.value.AutoValue;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryUtils;
import org.apache.beam.sdk.io.gcp.bigquery.DynamicDestinations;
import org.apache.beam.sdk.io.gcp.bigquery.TableDestination;
import org.apache.beam.sdk.io.gcp.bigquery.WriteResult;
import org.apache.beam.sdk.transforms.PTransform;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.ValueInSingleWindow;
import org.joda.time.Duration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@AutoValue
@SuppressWarnings("serial")
public abstract class BigQueryDynamicWriteTransform
    extends PTransform<PCollection<KV<String, TableRow>>, WriteResult> {
  public static final Logger LOG = LoggerFactory.getLogger(BigQueryDynamicWriteTransform.class);

  public abstract String projectId();

  public abstract String datasetId();

  public static Builder newBuilder() {
    return new AutoValue_BigQueryDynamicWriteTransform.Builder();
  }

  private static final String jsonSchema = "{"
      + "\"fields\":["
      + "{ \"description\": \"Card_Type_Code\", \"mode\": \"REQUIRED\", \"name\": \"Card_Type_Code\", \"type\": \"STRING\"},"
      + "{ \"description\": \"Card_Type_Full_Name\", \"mode\": \"REQUIRED\", \"name\": \"Card_Type_Full_Name\", \"type\": \"STRING\"},"
      + "{ \"description\": \"Issuing_Bank\", \"mode\": \"REQUIRED\", \"name\": \"Issuing_Bank\", \"type\": \"STRING\" },"
      + "{ \"description\": \"Card_Number\", \"mode\": \"REQUIRED\", \"name\": \"Card_Number\", \"type\": \"STRING\" },"
      + "{ \"description\": \"Card_Holders_Name\", \"mode\": \"REQUIRED\", \"name\": \"Card_Holders_Name\", \"type\": \"STRING\"},"
      + "{ \"description\": \"CVV2\", \"mode\": \"REQUIRED\", \"name\": \"CVVCVV2\", \"type\": \"STRING\"},"
      + "{ \"description\": \"Issue_Date\", \"mode\": \"REQUIRED\", \"name\": \"Issue_Date\", \"type\": \"STRING\"},"
      + "{ \"description\": \"Expiry_Date\", \"mode\": \"REQUIRED\", \"name\": \"Expiry_Date\", \"type\": \"STRING\"},"
      + "{ \"description\": \"Billing_Date\", \"mode\": \"REQUIRED\", \"name\": \"Billing_Date\", \"type\": \"STRING\"},"
      + "{ \"description\": \"Card_PIN\", \"mode\": \"REQUIRED\", \"name\": \"Card_PIN\", \"type\": \"STRING\"},"
      + "{ \"description\": \"Credit_Limit\", \"mode\": \"REQUIRED\", \"name\": \"Credit_Limit\", \"type\": \"STRING\"}"
      + "]"
      + "}";

  @AutoValue.Builder
  public abstract static class Builder {
    public abstract Builder setDatasetId(String projectId);

    public abstract Builder setProjectId(String datasetId);

    public abstract BigQueryDynamicWriteTransform build();
  }

  @Override
  public WriteResult expand(PCollection<KV<String, TableRow>> input) {

    return input.apply(
        "BQ Write",
        BigQueryIO.<KV<String, TableRow>>write()
            // .to(new BQDestination(datasetId(), projectId()))
            .to(projectId() + ":" + datasetId() + "." + "cc_10000_records")
            .withFormatFunction(
                element -> {
                  return element.getValue();
                })
            .withWriteDisposition(BigQueryIO.Write.WriteDisposition.WRITE_APPEND)
            .withCreateDisposition(BigQueryIO.Write.CreateDisposition.CREATE_IF_NEEDED)
            .withoutValidation()
            .withMethod(BigQueryIO.Write.Method.FILE_LOADS)
            .withTriggeringFrequency(Duration.standardSeconds(10))
            .withNumFileShards(1));
  }

  public class BQDestination
      extends DynamicDestinations<KV<String, TableRow>, KV<String, TableRow>> {
    private String datasetName;
    private String projectId;

    public BQDestination(String datasetName, String projectId) {
      this.datasetName = datasetName;
      this.projectId = projectId;
    }

    @Override
    public TableDestination getTable(KV<String, TableRow> destination) {
      TableDestination dest = new TableDestination(destination.getKey(), "DLP Transformation Storage Table");
      LOG.debug("Table Destination {}", dest.getTableSpec());
      return dest;
    }

    @Override
    public KV<String, TableRow> getDestination(ValueInSingleWindow<KV<String, TableRow>> element) {
      String key = element.getValue().getKey();
      String tableName = String.format("%s:%s.%s", projectId, datasetName, key);
      LOG.debug("Table Name {}", tableName);
      return KV.of(tableName, element.getValue().getValue());
    }

    @Override
    public TableSchema getSchema(KV<String, TableRow> destination) {
      String tableName = destination.getKey().split("\\.")[1];
      LOG.info("Table Name {}", tableName);
      switch (tableName) {
        case "dlp_inspection_result":
          return BigQueryUtils.toTableSchema(Util.dlpInspectionSchema);
        case "error_table":
          return BigQueryUtils.toTableSchema(Util.errorSchema);
        default:
          TableRow bqRow = destination.getValue();
          TableSchema schema = new TableSchema();
          List<TableFieldSchema> fields = new ArrayList<TableFieldSchema>();
          List<TableCell> cells = bqRow.getF();
          for (int i = 0; i < cells.size(); i++) {
            Map<String, Object> object = cells.get(i);
            String header = object.keySet().iterator().next();
            /** currently all BQ data types are set to String */
            fields.add(
                new TableFieldSchema().setName(Util.checkHeaderName(header)).setType("STRING"));
          }
          schema.setFields(fields);
          return schema;
      }
    }
  }
}
