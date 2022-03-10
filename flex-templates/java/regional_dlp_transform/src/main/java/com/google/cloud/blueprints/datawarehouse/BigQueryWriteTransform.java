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

package com.google.cloud.blueprints.datawarehouse;

import com.google.api.services.bigquery.model.TableRow;
import com.google.auto.value.AutoValue;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO;
import org.apache.beam.sdk.io.gcp.bigquery.WriteResult;
import org.apache.beam.sdk.transforms.PTransform;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.values.PCollection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@AutoValue
@SuppressWarnings("serial")
public abstract class BigQueryWriteTransform
    extends PTransform<PCollection<KV<String, TableRow>>, WriteResult> {
  public static final Logger LOG = LoggerFactory.getLogger(BigQueryWriteTransform.class);

  public abstract String projectId();

  public abstract String tableName();

  public abstract String bqSchema();

  public static Builder newBuilder() {
    return new AutoValue_BigQueryWriteTransform.Builder();
  }

  @AutoValue.Builder
  public abstract static class Builder {

    public abstract Builder setProjectId(String datasetId);

    public abstract Builder setTableName(String tableName);

    public abstract Builder setBqSchema(String bqSchema);

    public abstract BigQueryWriteTransform build();
  }

  @Override
  public WriteResult expand(PCollection<KV<String, TableRow>> input) {

    return input.apply(
        "BQ Write",
        BigQueryIO.<KV<String, TableRow>>write()
            .to(tableName())
            .withFormatFunction(
                element -> {
                  return element.getValue();
                })
            .withJsonSchema(getJsonSchema(bqSchema()))
            .withWriteDisposition(BigQueryIO.Write.WriteDisposition.WRITE_APPEND)
            .withCreateDisposition(BigQueryIO.Write.CreateDisposition.CREATE_IF_NEEDED)
            .withoutValidation()
            .withMethod(BigQueryIO.Write.Method.FILE_LOADS));
  }

  private static String getJsonSchema(String inputSchema) {
    String[] fields = inputSchema.split(",");
    String jsonSchema = "{ \"fields\": [";

    for (int i = 0; i < fields.length; i++) {
      jsonSchema += String.format("{\"name\": \"%s\", \"type\": \"%s\"}%s", fields[i].split(":")[0].trim(),
          fields[i].split(":")[1].trim(),
          i == fields.length - 1 ? "" : ",");
    }
    jsonSchema += "]}";
    LOG.debug(jsonSchema);
    return jsonSchema;
  }
}
