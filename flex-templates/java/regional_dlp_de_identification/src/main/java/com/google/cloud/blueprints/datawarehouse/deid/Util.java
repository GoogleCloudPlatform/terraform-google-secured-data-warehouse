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

import java.io.BufferedReader;
import java.io.IOException;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import com.google.common.base.Charsets;

import org.apache.beam.sdk.io.FileIO.ReadableFile;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Util {

    public static final Logger LOG = LoggerFactory.getLogger(Util.class);
    /** Expected only CSV file in GCS bucket. */
    public static final String ALLOWED_FILE_EXTENSION = String.valueOf("csv");
    /** Regular expression that matches valid BQ table IDs. */
    public static final Pattern TABLE_REGEXP = Pattern.compile("[-\\w$@]{1,1024}");
    /** Regular expression that matches valid BQ column name . */
    public static final Pattern COLUMN_NAME_REGEXP = Pattern.compile("^[A-Za-z_]+[A-Za-z_0-9]*$");

    /**
    * Receives a csv and returns a string with the name of the file, without
    * the .csv extension. The function also validates the file to match with the permitted extension, and the name is in
    * accordance with <a href="https://cloud.google.com/bigquery/docs/datasets#dataset-naming">BigQuery's naming restrictions</a>.
    *
    * @param  file CSV file
    * @return      the CSV file name without the extension .csv
    */
    public static String getAndValidateFileAttributes(ReadableFile file) {
        String csvFileName = file.getMetadata().resourceId().getFilename().toString();
        /** taking out .csv extension from file name e.g fileName.csv->fileName */
        String[] fileKey = csvFileName.split("\\.", 2);

        if (!fileKey[1].matches(ALLOWED_FILE_EXTENSION) || !TABLE_REGEXP.matcher(fileKey[0]).matches()) {
        throw new RuntimeException(
            "[Filename must contain a CSV extension "
                + " BQ table name must contain only letters, numbers, or underscores ["
                + fileKey[1]
                + "], ["
                + fileKey[0]
                + "]");
        }
        /** returning file name without extension */
        return fileKey[0];
    }

    /**
    * Receives the CSV file and returns his reader.
    *
    * @param  csvFile CSV file
    * @return         reader of the CSV file
    */
    public static BufferedReader getReader(ReadableFile csvFile) {
        BufferedReader br = null;
        ReadableByteChannel channel = null;
        /** read the file and create buffered reader */
        try {
        channel = csvFile.openSeekable();

        } catch (IOException e) {
        LOG.error("Failed to Read File {}", e.getMessage());
        throw new RuntimeException(e);
        }

        if (channel != null) {

        br = new BufferedReader(Channels.newReader(channel, Charsets.UTF_8.name()));
        }

        return br;
    }

    /**
    * Receives a CSV file reader and returns his headers.
    *
    * @param  reader file reader
    * @return        headers of the file
    */
    public static List<String> getFileHeaders(BufferedReader reader) {
        List<String> headers = new ArrayList<>();
        try {
        CSVRecord csvHeader = CSVFormat.DEFAULT.parse(reader).getRecords().get(0);
        csvHeader.forEach(
            headerValue -> {
                headers.add(headerValue);
            });
        } catch (IOException e) {
        LOG.error("Failed to get csv header values}", e.getMessage());
        throw new RuntimeException(e);
        }
        return headers;
    }

    /**
    * Receives a header name and transform it to be in accordance with
    * <a href="https://cloud.google.com/bigquery/docs/schemas#column_names">BigQuery's naming header restrictions</a>.
    *
    * @param  name header name
    * @return      header name according with BigQuery's restrictions
    */
    public static String checkHeaderName(String name) {
        /**
        * some checks to make sure BQ column names don't fail e.g. special characters
        */
        String checkedHeader = name.replaceAll("\\s", "_");
        checkedHeader = checkedHeader.replaceAll("'", "");
        checkedHeader = checkedHeader.replaceAll("/", "");
        if (!COLUMN_NAME_REGEXP.matcher(checkedHeader).matches()) {
        throw new IllegalArgumentException("Column name can't be matched to a valid format " + name);
        }
        return checkedHeader;
    }
}
