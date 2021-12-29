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
import logging

import apache_beam as beam
import apache_beam.transforms.window as window
from apache_beam.options.pipeline_options import (GoogleCloudOptions,
                                                  PipelineOptions)
from apache_beam.transforms import DoFn, ParDo, PTransform, BatchElements
from apache_beam.utils.annotations import experimental


def run(argv=None, save_main_session=True):
    """Build and run the pipeline."""
    parser = argparse.ArgumentParser()
    group = parser.add_argument_group()
    group_exclusive = parser.add_mutually_exclusive_group(required=True)
    group_exclusive.add_argument(
        '--query',
        help=(
            'Input query to retrieve data from Dataset. '
            'Example: `SELECT * FROM PROJECT:DATASET.TABLE LIMIT 100`.'
        )
    )
    group_exclusive.add_argument(
        '--input_table',
        help=(
            'Input BigQuery table for results specified as: '
            'PROJECT:DATASET.TABLE or DATASET.TABLE.'
        )
    )
    group.add_argument(
        '--output_table',
        required=True,
        help=(
            'Output BigQuery table for results specified as: '
            'PROJECT:DATASET.TABLE or DATASET.TABLE.'
        )
    )
    group.add_argument(
        '--bq_schema',
        required=True,
        help=(
            'Output BigQuery table schema specified as string with format: '
            'FIELD_1:STRING,FIELD_2:STRING,...'
        )
    )
    group.add_argument(
        '--dlp_project',
        required=True,
        help=(
            'ID of the project that holds the DLP template.'
        )
    )
    group.add_argument(
        '--dlp_location',
        required=False,
        help=(
            'The Location of the DLP template resource.'
        )
    )
    group.add_argument(
        '--deidentification_template_name',
        required=True,
        help=(
            'Name of the DLP Structured De-identification Template '
            'of the form "projects/<PROJECT>/locations/<LOCATION>'
            '/deidentifyTemplates/<TEMPLATE_ID>"'
        )
    )
    group.add_argument(
        "--window_interval_sec",
        default=30,
        type=int,
        help=(
            'Window interval in seconds for grouping incoming messages.'
        )
    )
    group.add_argument(
        "--batch_size",
        default=1000,
        type=int,
        help=(
            'Number of records to be sent in a batch in ',
            'the call to the Data Loss Prevention (DLP) API.'
        )
    )
    group.add_argument(
        "--dlp_transform",
        default='RE-IDENTIFY',
        required=True,
        help=(
            'DLP transformation type.'
        )
    )
    known_args, pipeline_args = parser.parse_known_args(argv)

    options = PipelineOptions(
        pipeline_args,
        save_main_session=True,
        streaming=True
    )

    with beam.Pipeline(options=options) as p:

        # Read from BigQuery into a PCollection.
        if known_args.query is not None:
            messages = (
                p
                | 'Read from BigQuery Table' >>
                beam.io.ReadFromBigQuery(
                    query=known_args.query
                )
                | 'Apply window' >> beam.WindowInto(
                    window.FixedWindows(known_args.window_interval_sec, 0)
                )
            )
        else:
            messages = (
                p
                | 'Read from BigQuery Table' >>
                beam.io.ReadFromBigQuery(
                    table=known_args.input_table
                )
                | 'Apply window' >> beam.WindowInto(
                    window.FixedWindows(known_args.window_interval_sec, 0)
                )
            )

        if known_args.dlp_transform == 'RE-IDENTIFY':
            transformed_messages = (
                messages
                | "Batching" >> BatchElements(
                    min_batch_size=known_args.batch_size,
                    max_batch_size=known_args.batch_size
                )
                | 'Convert dicts to table' >>
                beam.Map(from_list_dicts_to_table)
                | 'Call DLP re-identification' >>
                UnmaskDetectedDetails(
                    project=known_args.dlp_project,
                    location=known_args.dlp_location,
                    template_name=known_args.deidentification_template_name
                )
                | 'Convert table to dicts' >>
                beam.FlatMap(from_table_to_list_dict)
            )
        else:
            transformed_messages = (
                messages
                | "Batching" >> BatchElements(
                    min_batch_size=known_args.batch_size,
                    max_batch_size=known_args.batch_size
                )
                | 'Convert dicts to table' >>
                beam.Map(from_list_dicts_to_table)
                | 'Call DLP de-identification' >>
                MaskDetectedDetails(
                    project=known_args.dlp_project,
                    location=known_args.dlp_location,
                    template_name=known_args.deidentification_template_name
                )
                | 'Convert table to dicts' >>
                beam.FlatMap(from_table_to_list_dict)
            )

        # Write to BigQuery.
        transformed_messages | 'Write to BQ' >> beam.io.WriteToBigQuery(
            known_args.output_table,
            schema=known_args.bq_schema,
            create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED
        )


def normalize_data(data):
    """
    The template reads a json from PubSub that can be a single object
    or a List of objects. This function is used by a FlatMap transformation
    to normalize the input in to individual objects.
    See:
     - https://beam.apache.org/documentation/transforms/python/elementwise/flatmap/
    """  # noqa
    if isinstance(data, list):
        return data
    return [data]


def from_list_dicts_to_table(list_item):
    """
    Converts a Python list of dict object to a DLP API v2
    ContentItem with value Table.
    See:
     - https://cloud.google.com/dlp/docs/reference/rest/v2/ContentItem#Table
     - https://cloud.google.com/dlp/docs/inspecting-structured-text
    """
    headers = []
    rows = []
    for key in sorted(list_item[0]):
        headers.append({"name": key})
    for item in list_item:
        row = {"values": []}
        for item_key in sorted(item):
            row["values"].append({"string_value": item[item_key]})
        rows.append(row)
    table_item = {"table": {"headers": headers, "rows": rows}}
    return table_item


def from_table_to_list_dict(content_item):
    """
    Converts a DLP API v2 ContentItem of type Table with a single row
    to a Python dict object.
    See:
     - https://cloud.google.com/dlp/docs/reference/rest/v2/ContentItem#Table
     - https://cloud.google.com/dlp/docs/inspecting-structured-text
    """
    result = []
    for row in content_item.table.rows:
        new_item = {}
        for index, val in enumerate(content_item.table.headers):
            new_item[val.name] = row.values[index].string_value
        result.append(new_item)
    return result


@experimental()
class UnmaskDetectedDetails(PTransform):

    def __init__(
            self,
            project=None,
            location="global",
            template_name=None,
            reidentification_config=None,
            timeout=None):

        self.config = {}
        self.project = project
        self.timeout = timeout
        self.location = location

        if template_name is not None:
            self.config['reidentify_template_name'] = template_name
        else:
            self.config['reidentify_config'] = reidentification_config

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
            | ParDo(_ReidentifyFn(
                self.config,
                self.timeout,
                self.project,
                self.location
            )))


class _ReidentifyFn(DoFn):

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
            'parent': "projects/{}/locations/{}".format(
                self.project,
                self.location
            )
        }
        self.params.update(self.config)

    def process(self, element, **kwargs):
        operation = self.client.reidentify_content(
            item=element, **self.params)
        yield operation.item


@experimental()
class MaskDetectedDetails(PTransform):

    def __init__(
            self,
            project=None,
            location="global",
            template_name=None,
            deidentification_config=None,
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
            'parent': "projects/{}/locations/{}".format(
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
