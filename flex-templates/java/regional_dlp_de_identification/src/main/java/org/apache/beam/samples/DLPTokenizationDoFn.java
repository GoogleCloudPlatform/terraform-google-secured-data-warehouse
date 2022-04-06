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

import java.io.IOException;
import java.sql.SQLException;

import com.google.cloud.dlp.v2.DlpServiceClient;
import com.google.privacy.dlp.v2.ContentItem;
import com.google.privacy.dlp.v2.DeidentifyContentRequest;
import com.google.privacy.dlp.v2.DeidentifyContentRequest.Builder;
import com.google.privacy.dlp.v2.DeidentifyContentResponse;
import com.google.privacy.dlp.v2.LocationName;
import com.google.privacy.dlp.v2.Table;

import org.apache.beam.sdk.metrics.Distribution;
import org.apache.beam.sdk.metrics.Metrics;
import org.apache.beam.sdk.options.ValueProvider;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.values.KV;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
   * The {@link DLPTokenizationDoFn} class executes tokenization request by
   * calling DLP api. It uses DLP table as a content item as CSV file contains
   * fully structured data. DLP templates (e.g. de-identify, inspect) need to
   * exist before this pipeline runs. As response from the API is received,
   * this DoFn outputs KV of new table with table id as key.
   */
  public class DLPTokenizationDoFn extends DoFn<KV<String, Table>, KV<String, Table>> {

    public static final Logger LOG = LoggerFactory.getLogger(DLPTokenizationDoFn.class);

    private ValueProvider<String> dlpProjectId;
    private ValueProvider<String> dlpLocation;
    private DlpServiceClient dlpServiceClient;
    private ValueProvider<String> deIdentifyTemplateName;
    //private ValueProvider<String> inspectTemplateName;
    private boolean inspectTemplateExist;
    private Builder requestBuilder;
    private final Distribution numberOfRowsTokenized = Metrics.distribution(DLPTokenizationDoFn.class,
        "numberOfRowsTokenizedDistro");
    private final Distribution numberOfBytesTokenized = Metrics.distribution(DLPTokenizationDoFn.class,
        "numberOfBytesTokenizedDistro");

    public DLPTokenizationDoFn(
        ValueProvider<String> dlpProjectId,
        ValueProvider<String> dlpLocation,
        ValueProvider<String> deIdentifyTemplateName) {
      this.dlpProjectId = dlpProjectId;
      this.dlpLocation = dlpLocation;
      this.dlpServiceClient = null;
      this.deIdentifyTemplateName = deIdentifyTemplateName;
      this.inspectTemplateExist = false;
    }

    @Setup
    public void setup() {
      if (this.deIdentifyTemplateName.isAccessible()) {
        if (this.deIdentifyTemplateName.get() != null) {
          this.requestBuilder = DeidentifyContentRequest.newBuilder()
              .setParent(LocationName.of(this.dlpProjectId.get(), this.dlpLocation.get()).toString())
              .setDeidentifyTemplateName(this.deIdentifyTemplateName.get());
        }
      }
    }

    @StartBundle
    public void startBundle() throws SQLException {

      try {
        this.dlpServiceClient = DlpServiceClient.create();

      } catch (IOException e) {
        LOG.error("Failed to create DLP Service Client", e.getMessage());
        throw new RuntimeException(e);
      }
    }

    @FinishBundle
    public void finishBundle() throws Exception {
      if (this.dlpServiceClient != null) {
        this.dlpServiceClient.close();
      }
    }

    @ProcessElement
    public void processElement(ProcessContext c) {
      String key = c.element().getKey();
      Table nonEncryptedData = c.element().getValue();
      ContentItem tableItem = ContentItem.newBuilder().setTable(nonEncryptedData).build();
      this.requestBuilder.setItem(tableItem);
      DeidentifyContentResponse response = dlpServiceClient.deidentifyContent(this.requestBuilder.build());
      Table tokenizedData = response.getItem().getTable();
      numberOfRowsTokenized.update(tokenizedData.getRowsList().size());
      numberOfBytesTokenized.update(tokenizedData.toByteArray().length);
      c.output(KV.of(key, tokenizedData));
    }
  }