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
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.stream.Collectors;

import com.google.privacy.dlp.v2.FieldId;
import com.google.privacy.dlp.v2.Table;
import com.google.privacy.dlp.v2.Value;

import org.apache.beam.sdk.io.FileIO.ReadableFile;
import org.apache.beam.sdk.io.range.OffsetRange;
import org.apache.beam.sdk.options.ValueProvider;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.splittabledofn.OffsetRangeTracker;
import org.apache.beam.sdk.transforms.splittabledofn.RestrictionTracker;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.values.PCollectionView;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * The {@link CSVReader} class uses experimental Split DoFn to split each csv
 * file contents in chunks and process it in non-monolithic fashion.
 * For example: if a CSV file has 100 rows and batch size is set to 15, then
 * initial restrictions for the SDF will be 1 to 7 and split restriction will
 * be {{1-2},{2-3}..{7-8}} for parallel executions.
 */
public class CSVReader extends DoFn<KV<String, ReadableFile>, KV<String, Table>> {

    public static final Logger LOG = LoggerFactory.getLogger(CSVReader.class);

    private ValueProvider<Integer> batchSize;
    private PCollectionView<List<KV<String, List<String>>>> headerMap;
    /**
    * This counter is used to track number of lines processed against batch size.
    */
    private Integer lineCount;

    List<String> csvHeaders;

    public CSVReader(
        ValueProvider<Integer> batchSize,
        PCollectionView<List<KV<String, List<String>>>> headerMap) {
    this.batchSize = batchSize;
    this.headerMap = headerMap;
    this.csvHeaders = new ArrayList<>();
    }

    @ProcessElement
    public void processElement(ProcessContext c, RestrictionTracker<OffsetRange, Long> tracker)
        throws IOException {
        for (long i = tracker.currentRestriction().getFrom(); tracker.tryClaim(i); ++i) {
            lineCount = 1;

            String fileKey = c.element().getKey();
            try (BufferedReader br = Util.getReader(c.element().getValue())) {

                csvHeaders = getHeaders(c.sideInput(headerMap), fileKey);
                if (csvHeaders != null) {
                    List<FieldId> dlpTableHeaders = csvHeaders.stream()
                        .map(header -> FieldId.newBuilder().setName(header).build())
                        .collect(Collectors.toList());
                    List<Table.Row> rows = new ArrayList<>();
                    Table dlpTable = null;
                    /** finding out EOL for this restriction so that we know the SOL */
                    int endOfLine = (int) (i * batchSize.get().intValue());
                    int startOfLine = (endOfLine - batchSize.get().intValue());
                    /** skipping all the rows that's not part of this restriction */
                    br.readLine();
                    Iterator<CSVRecord> csvRows = CSVFormat.Builder.create(CSVFormat.DEFAULT).setSkipHeaderRecord(true).build().parse(br).iterator();
                        for (int line = 0; line < startOfLine; line++) {
                        if (csvRows.hasNext()) {
                            csvRows.next();
                        }
                    }
                    /**
                    * looping through buffered reader and creating DLP Table Rows equals to batch
                    */
                    while (csvRows.hasNext() && lineCount <= batchSize.get()) {

                        CSVRecord csvRow = csvRows.next();
                        rows.add(convertCsvRowToTableRow(csvRow));
                        lineCount += 1;
                    }
                    /** creating DLP table and output for next transformation */
                    dlpTable = Table.newBuilder().addAllHeaders(dlpTableHeaders).addAllRows(rows).build();
                    c.output(KV.of(fileKey, dlpTable));

                    LOG.debug(
                        "Current Restriction From: {}, Current Restriction To: {},"
                            + " StartofLine: {}, End Of Line {}, BatchData {}",
                        tracker.currentRestriction().getFrom(),
                        tracker.currentRestriction().getTo(),
                        startOfLine,
                        endOfLine,
                        dlpTable.getRowsCount());

                } else {

                    throw new RuntimeException("Header Values Can't be found For file Key " + fileKey);
                }
            }
        }
    }

    /**
    * SDF needs to define a @GetInitialRestriction method that can create a
    * restriction describing the complete work for a given element. For our
    * case this would be the total number of rows for each CSV file. We will
    * calculate the number of split required based on total number of rows
    * and batch size provided.
    *
    * @throws IOException
    *
    * @param  csvFile CSV file
    * @return         Initial Restriction range from 1 to totalSplit
    */
    @GetInitialRestriction
    public OffsetRange getInitialRestriction(@Element KV<String, ReadableFile> csvFile)
        throws IOException {

        int rowCount = 0;
        int totalSplit = 0;
        try (BufferedReader br = Util.getReader(csvFile.getValue())) {
            /** assume first row is header */
            int checkRowCount = (int) br.lines().count() - 1;
            rowCount = (checkRowCount < 1) ? 1 : checkRowCount;
            totalSplit = rowCount / batchSize.get().intValue();
            int remaining = rowCount % batchSize.get().intValue();
            /**
            * Adjusting the total number of split based on remaining rows. For example:
            * batch size of 15 for 100 rows will have total 7 splits. As it's a range
            * last split will have offset range {7,8}.
            */
            if (remaining > 0) {
                totalSplit = totalSplit + 2;

            } else {
                totalSplit = totalSplit + 1;
            }
        }

        LOG.debug("Initial Restriction range from 1 to: {}", totalSplit);
        return new OffsetRange(1, totalSplit);
    }

    /**
    * SDF needs to define a @SplitRestriction method that can split the initial
    * restriction to a number of smaller restrictions. For example: a initial
    * restriction of (x, N) as input and produces pairs (x, 0), (x, 1), …,
    * (x, N-1) as output.
    *
    * @param  csvFile  the CSV file
    * @param  range    range of the split
    * @param  out      object to return
    * @return          split of the initial restriction to a number of smaller restrictions
    */
    @SplitRestriction
    public void splitRestriction(
        @Element KV<String, ReadableFile> csvFile,
        @Restriction OffsetRange range,
        OutputReceiver<OffsetRange> out) {
    /** split the initial restriction by 1 */
        for (final OffsetRange p : range.split(1, 1)) {
            out.output(p);
        }
    }

    @NewTracker
    public OffsetRangeTracker newTracker(@Restriction OffsetRange range) {
        return new OffsetRangeTracker(new OffsetRange(range.getFrom(), range.getTo()));
    }

    private Table.Row convertCsvRowToTableRow(CSVRecord csvRow) {
        /** convert from CSV row to DLP Table Row */
        Iterator<String> valueIterator = csvRow.iterator();
        Table.Row.Builder tableRowBuilder = Table.Row.newBuilder();
        while (valueIterator.hasNext()) {
            String value = valueIterator.next();
            if (value != null) {
                tableRowBuilder.addValues(Value.newBuilder().setStringValue(value.toString()).build());
            } else {
                tableRowBuilder.addValues(Value.newBuilder().setStringValue("").build());
            }
        }

        return tableRowBuilder.build();
    }

    private List<String> getHeaders(List<KV<String, List<String>>> headerMap, String fileKey) {
        return headerMap.stream()
            .filter(map -> map.getKey().equalsIgnoreCase(fileKey))
            .findFirst()
            .map(e -> e.getValue())
            .orElse(null);
    }
}
