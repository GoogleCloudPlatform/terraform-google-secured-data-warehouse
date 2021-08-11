# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import absolute_import

import argparse
import json
import logging

import apache_beam as beam
from apache_beam.options.pipeline_options import (GoogleCloudOptions,
                                                  PipelineOptions)
from apache_beam.transforms import DoFn, ParDo, PTransform
from apache_beam.utils.annotations import experimental


def run(argv=None, save_main_session=True):
    """Build and run the pipeline."""
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--output_table',
        required=True,
        help=(
            'Output BigQuery table for results specified as: '
            'PROJECT:DATASET.TABLE or DATASET.TABLE.'))
    parser.add_argument(
        '--bq_schema',
        required=True,
        help=(
            'Output BigQuery table schema specified as: '
            'member:TYPE, group:TYPE'))
    parser.add_argument(
        '--dlp_project',
        required=True,
        help=(
            'ID of the project that holds the DLP template'))
    parser.add_argument(
        '--dlp_location',
        required=False,
        help=(
            'Location that holds the DLP template '))
    parser.add_argument(
        '--deidentification_template_name',
        required=True,
        help=(
            'ID of the project that holds the DLP template'))
    parser.add_argument(
        '--inspection_template_name',
        required=False,
        help=(
            'ID of the project that holds the DLP template'))
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        '--input_topic',
        help=(
            'Input PubSub topic of the form '
            '"projects/<PROJECT>/topics/<TOPIC>".'))
    group.add_argument(
        '--input_subscription',
        help=(
            'Input PubSub subscription of the form '
            '"projects/<PROJECT>/subscriptions/<SUBSCRIPTION>."'))
    known_args, pipeline_args = parser.parse_known_args(argv)

    options = PipelineOptions(
        pipeline_args,
        save_main_session=True,
        streaming=True
    )

    with beam.Pipeline(options=options) as p:

        # Read from PubSub into a PCollection.
        if known_args.input_subscription:
            messages = (
                p
                | 'Read from Pub/Sub' >>
                beam.io.ReadFromPubSub(
                    subscription=known_args.input_subscription
                ).with_output_types(bytes)
                | 'UTF-8 bytes to string' >>
                beam.Map(lambda msg: msg.decode("utf-8"))
                | 'Parse JSON payload' >>
                beam.Map(json.loads)
                | 'Flatten lists' >>
                beam.FlatMap(normalize_data)
            )
        else:
            messages = (
                p
                | 'Read from Pub/Sub' >>
                beam.io.ReadFromPubSub(
                    topic=known_args.input_topic
                ).with_output_types(bytes)
                | 'UTF-8 bytes to string' >>
                beam.Map(lambda msg: msg.decode("utf-8"))
                | 'Parse JSON payload' >>
                beam.Map(json.loads)
                | 'Flatten lists' >>
                beam.FlatMap(normalize_data)
            )

        de_identified_messages = (
            messages
            | 'convert  dict to table item' >>
            beam.Map(from_dict_to_table)
            | 'Call DLP de-identification' >>
            MaskDetectedDetails(
                project=known_args.dlp_project,
                location=known_args.dlp_location,
                template_name=known_args.deidentification_template_name,
                inspection_template_name=known_args.inspection_template_name
            )
            | 'convert table item to dict' >>
            beam.Map(from_table_to_dict)
        )

        # Write to BigQuery.
        de_identified_messages | 'Write to BQ' >> beam.io.WriteToBigQuery(
            known_args.output_table,
            schema=known_args.bq_schema,
            create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED
        )


def normalize_data(data):
    if isinstance(data, list):
        return data
    return [data]


def from_dict_to_table(item):
    headers = []
    rows = []
    rows.append({"values": []})
    for key in item.keys():
        headers.append({"name": key})
        rows[0]["values"].append({"string_value": item[key]})
    table_item = {"table": {"headers": headers, "rows": rows}}
    return table_item


def from_table_to_dict(table_item):
    new_dict = {}
    row_zero = None
    for index, val in enumerate(table_item.table.headers):
        row_zero = table_item.table.rows[0]
        new_dict[val.name] = row_zero.values[index].string_value
    return new_dict


@experimental()
class MaskDetectedDetails(PTransform):

    def __init__(
            self,
            project=None,
            location="global",
            template_name=None,
            deidentification_config=None,
            inspection_template_name=None,
            inspection_config=None,
            timeout=None):

        self.config = {}
        self.project = project
        self.timeout = timeout
        self.location = location

        if template_name is not None:
            self.config['deidentify_template_name'] = template_name
        else:
            self.config['deidentify_config'] = deidentification_config

    def expand(self, pcoll):
        if self.project is None:
            self.project = pcoll.pipeline.options.view_as(
                GoogleCloudOptions).project
        if self.project is None:
            raise ValueError(
                'GCP project name needs to be specified '
                'in "project" pipeline option')
        return (
            pcoll
            | ParDo(_DeidentifyFn(
                self.config,
                self.timeout,
                self.project,
                self.location
            )))


class _DeidentifyFn(DoFn):

    def __init__(
        self,
        config=None,
        timeout=None,
        project=None,
        location=None,
        client=None
    ):
        self.config = config
        self.timeout = timeout
        self.client = client
        self.project = project
        self.location = location
        self.params = {}

    def setup(self):
        from google.cloud import dlp_v2
        if self.client is None:
            self.client = dlp_v2.DlpServiceClient()
        self.params = {
            'timeout': self.timeout,
            'parent': self.client.location_path(
                self.project,
                self.location
            )
        }
        self.params.update(self.config)

    def process(self, element, **kwargs):
        operation = self.client.deidentify_content(
            item=element, **self.params)
        yield operation.item


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    run()
