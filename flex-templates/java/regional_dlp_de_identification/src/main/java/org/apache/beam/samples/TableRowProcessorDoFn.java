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

import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

import com.google.api.services.bigquery.model.TableRow;
import com.google.privacy.dlp.v2.Table;

import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.values.KV;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * The {@link TableRowProcessorDoFn} class process tokenized DLP tables and
 * convert them to BigQuery Table Row.
 */
public class TableRowProcessorDoFn extends DoFn<KV<String, Table>, KV<String, TableRow>> {

  public static final Logger LOG = LoggerFactory.getLogger(TableRowProcessorDoFn.class);

  @ProcessElement
  public void processElement(ProcessContext c) {
    Table tokenizedData = c.element().getValue();
    List<String> headers = tokenizedData.getHeadersList().stream()
        .map(fid -> fid.getName())
        .collect(Collectors.toList());
    List<Table.Row> outputRows = tokenizedData.getRowsList();
    if (outputRows.size() > 0) {
      for (Table.Row outputRow : outputRows) {
        if (outputRow.getValuesCount() != headers.size()) {
          throw new IllegalArgumentException(
              "CSV file's header count must exactly match with data element count");
        }
        c.output(
            KV.of(
                c.element().getKey(),
                createBqRow(outputRow, headers.toArray(new String[headers.size()]))));
      }
    }
  }

  /**
  * Creates a BigQuery row using the tokenized values by DLP passed. The function
  * connects the headers to respective values that are transformed to Strings.
  *
  * @param  tokenizedValue Table row tokenized by DLP API
  * @param  headers        Headers of the table
  * @return                BigQuery row
  */
  //@CreateBqRow
  private static TableRow createBqRow(Table.Row tokenizedValue, String[] headers) {
    TableRow bqRow = new TableRow();
    AtomicInteger headerIndex = new AtomicInteger(0);
    tokenizedValue
        .getValuesList()
        .forEach(
            value -> {
              String checkedHeaderName = Util.checkHeaderName(headers[headerIndex.getAndIncrement()].toString());
              bqRow.set(checkedHeaderName, value.getStringValue());
            });
    return bqRow;
  }
}
