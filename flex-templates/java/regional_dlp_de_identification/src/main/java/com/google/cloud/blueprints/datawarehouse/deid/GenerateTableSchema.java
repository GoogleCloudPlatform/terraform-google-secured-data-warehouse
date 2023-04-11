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

import static org.apache.beam.sdk.io.gcp.bigquery.BigQueryHelpers.toJsonString;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.google.api.services.bigquery.model.TableFieldSchema;
import com.google.api.services.bigquery.model.TableSchema;

import org.apache.beam.sdk.io.FileIO.ReadableFile;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.values.KV;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * The {@link GenerateTableSchema} auto-detect and generate the BigQuery table schema
 * from the read file headers.
 */
public class GenerateTableSchema extends DoFn<KV<String, Iterable<ReadableFile>>, KV<String, String>> {

    public static final Logger LOG = LoggerFactory.getLogger(GenerateTableSchema.class);

    private String outputBQTable;

    public GenerateTableSchema(
        String outputBQTable) {
        this.outputBQTable = outputBQTable;
    }

    @ProcessElement
    public void processElement(ProcessContext c) {
        c.element()
            .getValue()
            .forEach(
                file -> {
                    try (BufferedReader br = Util.getReader(file)) {
                        List<String> headers = Util.getFileHeaders(br);

                        TableSchema schema = new TableSchema();
                        List<TableFieldSchema> fields = new ArrayList<TableFieldSchema>();

                        for (int i = 0; i < headers.size(); i++) {
                            fields.add(new TableFieldSchema().setName(Util.checkHeaderName(headers.get(i))).setType("STRING"));
                        }

                        schema.setFields(fields);
                        c.output(KV.of(this.outputBQTable, toJsonString(schema)));

                    } catch (IOException e) {
                        LOG.error("Failed to Read File {}", e.getMessage());
                        throw new RuntimeException(e);
                    }
                }
            );
        }
  }