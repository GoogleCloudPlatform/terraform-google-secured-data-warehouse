# User Guide

## Deploy Dataflow Jobs in the Secured Data Warehouse
<!--
TODO: ESTAMOS USANDO O TEMPLATE (JAVA) DO NOSSO EXEMPLO
- DEVEMOS USA-LO?
- DEVEMOS EVIDENCIAR ISSO?
- SE SIM, COMO?
-->
Make sure you have input and output BigQuery table available with correct data (and corresponding DLP template).

To deploy a dataflow flex job you must specify this following inputs:

- Job Name
- Template File Gcs Location
- Input Bigquery Table
- Output Bigquery Dataset
- Deidentify Template Name
- Dlp Project Id
- Dlp Location
- Confidential Data Project Id
- Dlp Transform
- Batch Size
- Project Id
- Staging Location
- Dataflow Kms Key
- Service Account Email
- Subnetwork
- Temporary Location
- Region

Também informe os parametros que são dependentes do templete:

- Output Bigquery Dataset
- Deidentify Template Name
- Dlp Project Id
- Dlp Location
- Confidential Data Project Id
- Dlp Transform
- Batch Size
- Project Id
- Staging Location

Nesses exemplos estamos considerando o template deployado

<!-- TODO: COMO MONSTRAR A EQUIVALENCIA DOS OUTPUTS DO MODULO -->

For more details about Dataflow Jobs deploys see [Deploying a Pipeline]((https://cloud.google.com/dataflow/docs/guides/deploying-a-pipeline)) documentation.

### Deploying with Terraform

Use the Dataflow Flex Job Template [submodule](../modules/dataflow-flex-job/README.md).

### Deploying with GCP Console

To deploy a dataflow flex job on the **GCP Console**, follow these steps:

1. [Log in](https://console.cloud.google.com/) to the Cloud Console.
1. Select your Google Cloud project.
1. Click the menu in the upper left corner.
1. Navigate to the Big Data section and click Dataflow.
1. Click the button named *Create Job From Template*, in the right side of the title of this page.
1. In the *Create job from a template* [page](https://console.cloud.google.com/dataflow/createjob)
<!--  TODO: COMO CONTINUAR? -->

### Deploying with Gcloud Command

<!--
TODO: ONDE ENCAIXAR ESSA DOCUMENTAÇÃO?
https://cloud.google.com/sdk/gcloud/reference/dataflow/jobs/run
-->

You can run the following commands to create a **Java** Dataflow Flex Job using the **Gcloud Command**:

```sh

export JOB_NAME=<JOB_NAME>
export TEMPLATE_FILE_GCS_LOCATION=<TEMPLATE_FILE_GCS_LOCATION>
export INPUT_BIGQUERY_TABLE=<INPUT_BIGQUERY_TABLE>
export OUTPUT_BIGQUERY_DATASET=<OUTPUT_BIGQUERY_DATASET>
export DEIDENTIFY_TEMPLATE_NAME=<DEIDENTIFY_TEMPLATE_NAME>
export DLP_PROJECT_ID=<DLP_PROJECT_ID>
export DLP_LOCATION=<DLP_LOCATION>
export CONFIDENTIAL_DATA_PROJECT_ID=<CONFIDENTIAL_DATA_PROJECT_ID>
export DLP_TRANSFORM=<DLP_TRANSFORM>
export BATCH_SIZE=<BATCH_SIZE>
export PROJECT_ID=<PROJECT_ID>
export STAGING_LOCATION=<STAGING_LOCATION>
export DATAFLOW_KMS_KEY=<DATAFLOW_KMS_KEY>
export SERVICE_ACCOUNT_EMAIL=<SERVICE_ACCOUNT_EMAIL>
export SUBNETWORK=<SUBNETWORK>
export TEMP_LOCATION=<TEMP_LOCATION>
export REGION=<REGION>

gcloud dataflow flex-template run "${JOB_NAME}" \
    --template-file-gcs-location="${TEMPLATE_FILE_GCS_LOCATION}" \
    --parameters inputBigQueryTable="${INPUT_BIGQUERY_TABLE}" \
    --parameters outputBigQueryDataset="${OUTPUT_BIGQUERY_DATASET}" \
    --parameters deidentifyTemplateName="${DEIDENTIFY_TEMPLATE_NAME}" \
    --parameters dlpProjectId="${DLP_PROJECT_ID}" \
    --parameters dlpLocation="${DLP_LOCATION}" \
    --parameters confidentialDataProjectId="${CONFIDENTIAL_DATA_PROJECT_ID}" \
    --parameters dlpTransform="${DLP_TRANSFORM}" \
    --parameters batchSize="${BATCH_SIZE}" \
    --project="${PROJECT_ID}" \
    --staging-location="${STAGING_LOCATION}" \
    --dataflow-kms-key="${DATAFLOW_KMS_KEY}" \
    --service-account-email="${SERVICE_ACCOUNT_EMAIL}" \
    --subnetwork="${SUBNETWORK}" \
    --temp-location="${TEMP_LOCATION}" \
    --region="${REGION}" \
    --disable-public-ips \
    --enable-streaming-engine

```

For more details about gcloud dataflow flex-template command see the command [documentation](https://cloud.google.com/sdk/gcloud/reference/dataflow/flex-template/run).
