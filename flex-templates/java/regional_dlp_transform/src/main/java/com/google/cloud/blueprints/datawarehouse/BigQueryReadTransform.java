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
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO;
import org.apache.beam.sdk.transforms.PTransform;
import org.apache.beam.sdk.transforms.WithKeys;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.values.PBegin;
import org.apache.beam.sdk.values.PCollection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@AutoValue
@SuppressWarnings("serial")
public abstract class BigQueryReadTransform
    extends PTransform<PBegin, PCollection<KV<String, TableRow>>> {
  public static final Logger LOG = LoggerFactory.getLogger(BigQueryReadTransform.class);

  public abstract String tableRef();

  @AutoValue.Builder
  public abstract static class Builder {

    public abstract Builder setTableRef(String tableRef);

    public abstract BigQueryReadTransform build();
  }

  public static Builder newBuilder() {
    return new AutoValue_BigQueryReadTransform.Builder();
  }

  @Override
  public PCollection<KV<String, TableRow>> expand(PBegin input) {

    return input
        .apply(
            "ReadFromBigQuery",
            BigQueryIO.readTableRows().from(tableRef())
        )
        .apply(
            "AddTableNameAsKey",
            WithKeys.of(tableRef())
        );
  }
}
