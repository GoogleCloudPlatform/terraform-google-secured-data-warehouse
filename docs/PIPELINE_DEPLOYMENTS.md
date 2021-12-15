# Pipeline deployments

The *Secured Data Warehouse Module* creates a secured Bigquery Data Warehouse infrastructure.
To use this infrastructure to deploy new Dataflow Flex Pipelines use the instructions in the following sections.

We assume you are familiar with [Deploying a Pipeline](https://cloud.google.com/dataflow/docs/guides/deploying-a-pipeline).

## *Secured Data Warehouse Module* deployment

It is necessary configure some controls for the deployment of the Secured Data Warehouse to allow user to create Dataflow Flex pipelines.

The Secured Data Warehouse module uses [VPC Service Controls](https://cloud.google.com/vpc-service-controls/docs/service-perimeters).

The identity deploying the Dataflow job must be in the [access level](https://cloud.google.com/access-context-manager/docs/create-basic-access-level#members-example) of the perimeter. You can add it using the input `perimeter_additional_members` of the *Secured Data Warehouse Module*.

To use a private template repository outside of the perimeter, the identity deploying the Dataflow job must be in a egress rule that allow the Dataflow templates to be fetched. In the *Secured Data Warehouse Module* you configure it using the appropriated list below.

- For the **confidential perimeter**, the identity needs to be added in the input `confidential_data_dataflow_deployer_identities` of the *Secured Data Warehouse Module*.
- For the **data ingestion perimeter**, the identity needs to be added in the input `data_ingestion_dataflow_deployer_identities` of the *Secured Data Warehouse Module*.

## Requirements

### Apis

All the required APIs to deploy the module had to be enabled. See the list of [APIs](../README.md#apis) in the README file.
Ensured that all the *additional APIs* your Dataflow pipeline needs are enabled too.

### Service Accounts Roles

You may need grant *additional roles* for Dataflow Controller Service Accounts created by the module to be able run your Dataflow Pipeline.

You can check the current roles associated with the Services Accounts in the files linked below:

- Data ingestion Dataflow Controller Service Account [roles](../modules/data-ingestion/service_accounts.tf)
- Confidential Data Dataflow Controller Service Account [roles](../modules/confidential-data/service_accounts.tf)

### Subnetwork

The subnetwork is a [requirement](https://cloud.google.com/dataflow/docs/guides/specifying-networks#specifying_a_network_and_a_subnetwork)
to deploy the *Dataflow Pipelines* in the *Secured Data Warehouse Module*.

We do not recommend the usage of [Default Network](https://cloud.google.com/vpc/docs/vpc#default-network) in the *Secured Data Warehouse Module*.

If you are using Shared VPC, make sure to add them as Trusted subnetworks using `trusted_subnetworks` variable. You can check more about it in the
*Secured Data Warehouse Module* [inputs](../README.md#inputs) section.

The subnetwork must be [configured for Private Google Access](https://cloud.google.com/vpc/docs/configure-private-google-access).
Make sure you have configured all the [firewall rules](#firewall-rules) and [DNS configurations](#dns-configurations) listed in the sections below.

#### Firewall rules

- [All the egress should be denied](https://cloud.google.com/vpc-service-controls/docs/set-up-private-connectivity#configure-firewall).
- [Allow only Restricted API Egress by TPC at 443 port](https://cloud.google.com/vpc-service-controls/docs/set-up-private-connectivity#configure-firewall).
- [Allow only Private API Egress by TPC at 443 port](https://cloud.google.com/vpc-service-controls/docs/set-up-private-connectivity#configure-firewall).
- [Allow ingress Dataflow workers by TPC at ports 12345 and 12346](https://cloud.google.com/dataflow/docs/guides/routes-firewall#example_firewall_ingress_rule).
- [Allow egress Dataflow workers by TPC at ports 12345 and 12346](https://cloud.google.com/dataflow/docs/guides/routes-firewall#example_firewall_egress_rule).

#### DNS configurations

- [Restricted Google APIs](https://cloud.google.com/vpc-service-controls/docs/set-up-private-connectivity#configure-routes).
- [Private Google APIs](https://cloud.google.com/vpc/docs/configure-private-google-access).
- [Restricted gcr.io](https://cloud.google.com/vpc-service-controls/docs/set-up-gke#configure-dns).
- [Restricted Artifact Registry](https://cloud.google.com/vpc-service-controls/docs/set-up-gke#configure-dns).

## Best Practice for Dataflow Flex Template Usage

The *Secured Data Warehouse Module* provides resources to deploy secured Dataflow Pipeline.
We highly recommend you to use them to deploy your Dataflow Pipeline.

### Temporary and Staging Location

Use the appropriated [output](../README.md#outputs) of the main module as the Temporary and Staging Location bucket in the
[pipeline options](https://cloud.google.com/dataflow/docs/guides/setting-pipeline-options#setting_required_options):

- Data ingestion project: `data_ingestion_dataflow_bucket_name`.
- Confidential Data project: `confidential_data_dataflow_bucket_name`.

### Dataflow Worker Service Account

Use the appropriated [output](../README.md#outputs) of the main module as the
[Dataflow Controller Service Account](https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_worker_service_account):

- Data ingestion project: `dataflow_controller_service_account_email`.
- Confidential Data project: `confidential_dataflow_controller_service_account_email`.

### Customer Managed Encryption Key

Use the appropriated [output](../README.md#outputs) of the main module as the [Dataflow KMS Key](https://cloud.google.com/dataflow/docs/guides/customer-managed-encryption-keys):

- Data ingestion project: `cmek_data_ingestion_crypto_key`
- Confidential project: `cmek_reidentification_crypto_key`

### Disable Public IPs

[Disabling Public IPs helps to better secure you data processing infrastructure.](https://cloud.google.com/dataflow/docs/guides/routes-firewall#turn_off_external_ip_address).
Make sure you have your subnetwork configured as [Subnetwork section](#subnetwork) details.

### Enable Streaming Engine

Enabling Streaming Engine it is important to ensure all the performance benefits of the infrastructure. You can learn more about it in the [documentation](https://cloud.google.com/dataflow/docs/guides/deploying-a-pipeline#streaming-engine).

## Deploying Dataflow Flex Jobs

We recommend the usage of [Flex Job Templates](https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates).
You can learn more about the differences between Classic and Flex Templates [here](https://cloud.google.com/dataflow/docs/concepts/dataflow-templates#evaluating-which-template-type-to-use).

### Deploying with Terraform

Use the Dataflow Flex Job Template [submodule](../modules/dataflow-flex-job/README.md).
See [Tutorial Standalone example](../examples/tutorial-standalone/README.md) for details.

### Deploying with `gcloud` Command

You can run the following commands to create a **Java** Dataflow Flex Job using the **gcloud command**:

```sh

export PROJECT_ID=<PROJECT_ID>
export DATAFLOW_BUCKET=<DATAFLOW_BUCKET>
export DATAFLOW_KMS_KEY=<DATAFLOW_KMS_KEY>
export SERVICE_ACCOUNT_EMAIL=<SERVICE_ACCOUNT_EMAIL>
export SUBNETWORK=<SUBNETWORK_SELF_LINK>

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

For more details about `gcloud dataflow flex-template` see the command [documentation](https://cloud.google.com/sdk/gcloud/reference/dataflow/flex-template/run).

## Common tasks

### How do I rerun the job for new data?

#### Streaming Dataflow

##### Storage to Bigquery

If you are using our [Tutorial Standalone Example](../examples/tutorial-standalone/README.md),
the de-identification Dataflow deployed has hardcoded the file name as the `inputFilePattern` parameter.

You must change the pattern for some who is more usable for you, for example: `*.csv`for all CSV files in the storage
or `*2021-12-14-0000.csv` for any files in the date and hour in the bucket.
After change the [`inputFilePattern`](../examples/tutorial-standalone/main.tf#L138)
you must re-deploy the job.

Since the de-identification Dataflow is a streaming one, any new file match the pattern will be ingested.

##### Pub/Sub to Bigquery

If you are using our [Regional DLP Example](../examples/regional-dlp/README.md), the Dataflow deployed is
already waiting for new input data in the topic. You just need do publish a new message with the format
expected by the template. You can check how publishing messages [here](https://cloud.google.com/pubsub/docs/publisher).

#### Batch Dataflow

##### Bigquery to Bigquery

If you are using our [Tutorial Standalone Example](../examples/tutorial-standalone/README.md),
the de-identification Dataflow deployed has hardcoded the table name as the `inputBigQueryTable` parameter.

You must change the pattern for the table name or pattern you want to ingest. After change the [`inputBigQueryTable`](../examples/tutorial-standalone/main.tf#L175)
you must re-deploy the job.

__Note:__ All Batch Dataflow JObs at the end of execution, it will stop.
If you want to trigger again, you must do a new deploy of the Dataflow Job.

### How do I send streaming data through and how to check it's been de-id?

### What if I have my own flex templates in a different project?
