# User Guide

## Deploy Dataflow Jobs in the Secured Data Warehouse

We assume you are familiar with [Deploying a Pipeline]((https://cloud.google.com/dataflow/docs/guides/deploying-a-pipeline)) documentation.

### VPC-SC

The Secured Data Warehouse module provide a infrastructure that uses [VPC-SC](https://cloud.google.com/vpc-service-controls/docs/service-perimeters).

Therefore, you must be sure that the identity deploying the Dataflow job is in the [access level](https://cloud.google.com/access-context-manager/docs/create-basic-access-level#members-example) of the perimeter. You can add it using the input `perimeter_additional_members` of the *Secured Data Warehouse Module*.

To use a private template repository outside of the perimeter, the identity deploying the Dataflow job must be in a egress rule that allow the Dataflow templates to be fetched. In the *Secured Data Warehouse Module* you configure it using the correct list indicated below.

- For the **confidential perimeter**, the identity needs to be added in the input `confidential_data_dataflow_deployer_identities` of the *Secured Data Warehouse Module*.
- For the **data ingestion perimeter**, the identity needs to be added in the input `data_ingestion_dataflow_deployer_identities` of the *Secured Data Warehouse Module*.

### Pipeline requirements

<!-- Ensured that the additional apis that your pipeline need are able. -->
The projects used in the *Secured Data Warehouse Module* must have some [apis enabled](../README.md#apis). Ensured that all the additional apis that your Dataflow pipeline need are enable too.

<!-- Section to user study the template and APIS and required roles. -->

### Opinionated Dataflow Flex Template Usage

- Use the staging/temp bucket created by the main module
- Use the appropriate Service Account provider by the main module
- Use the appropriate kms key

### Deploying with Terraform

Use the Dataflow Flex Job Template [submodule](../modules/dataflow-flex-job/README.md). See [Tutorial Standalone example](../examples/tutorial-standalone/README.md) for details.

### Deploying with GCP Console

To deploy a Dataflow Job on the **GCP Console**, follow these steps in these documentation:

- [Classic Template](https://cloud.google.com/dataflow/docs/guides/templates/provided-streaming#text-files-on-cloud-storage-to-bigquery-stream).
- [Flex Template](https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates#java_2).

### Deploying with Gcloud Command

**Flex Template**

You can run the following commands to create a **Java** Dataflow Flex Job using the **Gcloud Command**:

```sh

export PROJECT_ID=<PROJECT_ID>
export DATAFLOW_BUCKET=<DATAFLOW_BUCKET>
export DATAFLOW_KMS_KEY=<DATAFLOW_KMS_KEY>
export SERVICE_ACCOUNT_EMAIL=<SERVICE_ACCOUNT_EMAIL>
export SUBNETWORK=<SUBNETWORK>

gcloud dataflow flex-template run "TEMPLATE_NAME`date +%Y%m%d-%H%M%S`" \
    --template-file-gcs-location="TEMPLATE_NAME_LOCATION" \
    --project="${PROJECT_ID}" \
    --staging-location="${DATAFLOW_BUCKET}/staging/" \
    --temp-location="${DATAFLOW_BUCKET}/tmp/" \
    --dataflow-kms-key="${DATAFLOW_KMS_KEY}" \
    --service-account-email="${SERVICE_ACCOUNT_EMAIL}" \
    --subnetwork="${SUBNETWORK}" \
    --region="us-east4" \
    --disable-public-ips \
    --enable-streaming-engine

```

For more details about gcloud dataflow flex-template command see the command [documentation](https://cloud.google.com/sdk/gcloud/reference/dataflow/flex-template/run).

**Classic Template**

You can run the following commands to create a **Java** Dataflow Flex Job using the **Gcloud Command**:

```sh

COMMAND

```

For more details about gcloud dataflow ***** command see the command [documentation](https://cloud.google.com/sdk/gcloud/reference/dataflow/jobs/run).
