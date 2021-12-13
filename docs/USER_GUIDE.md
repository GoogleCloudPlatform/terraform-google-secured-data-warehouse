<!--I think this user guide is misleading. This doc is mainly for p -->
<!-- This is an initial version of User Guide, we started adding the main pain point of usage,
deploy Dataflow jobs, but it should not be only about it. This doc should also contains more tips about usage, adding Alida and user's feedbacks -->

# User Guide

## Deploy Dataflow Jobs in the Secured Data Warehouse

We assume you are familiar with [Deploying a Pipeline](https://cloud.google.com/dataflow/docs/guides/deploying-a-pipeline).

### VPC Service Controls

The Secured Data Warehouse module provide a infrastructure that uses [VPC Service Controls](https://cloud.google.com/vpc-service-controls/docs/service-perimeters).

The identity deploying the Dataflow job must be in the [access level](https://cloud.google.com/access-context-manager/docs/create-basic-access-level#members-example) of the perimeter. You can add it using the input `perimeter_additional_members` of the *Secured Data Warehouse Module*.

To use a private template repository outside of the perimeter, the identity deploying the Dataflow job must be in a egress rule that allow the Dataflow templates to be fetched. In the *Secured Data Warehouse Module* you configure it using the appropriated list below.

- For the **confidential perimeter**, the identity needs to be added in the input `confidential_data_dataflow_deployer_identities` of the *Secured Data Warehouse Module*.
- For the **data ingestion perimeter**, the identity needs to be added in the input `data_ingestion_dataflow_deployer_identities` of the *Secured Data Warehouse Module*.

### Pipeline requirements

All the required APIs to deploy the module had to be enabled. See the list of [APIs](../README.md#apis) in the README file.
Ensured that all the additional APIs your Dataflow pipeline needs are enabled too.

Also make sure that the two Dataflow Controller Service Accounts created by the module have all the roles needed to run the Dataflow Pipeline.

<!--I'd like to avoid dual maintenace in github markdown docs and guide. -->
You can check the current roles associated with the Services Accounts in the files below:

- [Data ingestion Dataflow Controller Service Account roles](../modules/data-ingestion/service_accounts.tf)
- [Confidential Data Dataflow Controller Service Account roles](../modules/confidential-data/service_accounts.tf)

<!--Is it opinionated or rather best practice -->
<!-- Some of the points in this section must be done, if the user does not follow the instruction he may face errors during deploy new jobs-->
### Opinionated Dataflow Flex Template Usage

The following outputs provided by the *Secured Data Warehouse Module*, must be used as inputs to a new Dataflow Job:

<!--avoid use or / . use same term in public doc -->
<!--Some template asked to use the Temporary and Staging Location. -->
#### Temporary and Staging Location

Use the appropriated [output](../README.md#outputs) of the main module as the Temporary and Staging Location bucket in the [pipeline options](https://cloud.google.com/dataflow/docs/guides/setting-pipeline-options#setting_required_options):

- Data ingestion project: `data_ingestion_dataflow_bucket_name`.
- Confidential Data project: `confidential_data_dataflow_bucket_name`.

#### Dataflow Worker Service Account

Use the appropriated [output](../README.md#outputs) of the main module as the [Dataflow Controller Service Account](https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_worker_service_account):

- Data ingestion project: `dataflow_controller_service_account_email`.
- Confidential Data project: `confidential_dataflow_controller_service_account_email`.

#### Customer Managed Encryption Key

Use the appropriated [output](../README.md#outputs) of the main module as the [Dataflow KMS Key](https://cloud.google.com/dataflow/docs/guides/customer-managed-encryption-keys):

- Data ingestion project: `cmek_data_ingestion_crypto_key`
- Confidential project: `cmek_reidentification_crypto_key`

### Deploying with Terraform

Use the Dataflow Flex Job Template [submodule](../modules/dataflow-flex-job/README.md). See [Tutorial Standalone example](../examples/tutorial-standalone/README.md) for details.

<!--
i'd like user focused actions described as additional topics . consider adding:
I suggest to scope this down to

can't we just point to the cloud build file. don't need to rewrite the code in docs, right?
 -->

### Deploying with GCP Console

To deploy a Dataflow Job on the **GCP Console** in the *Secured Data Warehouse*, follow
these instructions:

#### Classic Template

When deploying a Classic Template provide values for these optional parameters:

- Set **Worker IP Address Configuration** to `Private` to [Disabled Public IPs](https://cloud.google.com/dataflow/docs/guides/specifying-networks#public_ip_parameter).
- Check the [Enable Streaming Engine](https://cloud.google.com/dataflow/docs/guides/deploying-a-pipeline#streaming-engine) option.
- Use the [storage bucket](#stagingtemp-bucket) created as the **Temporary location**.
- Use the [Dataflow KMS Key](#customer-managed-encryption-key) created as the **custom-managed encryption key (CMEK)**.
- Use the [Dataflow Worker Service Account](#dataflow-worker-service-account) created as the **service account email**.
- Provide your [subnetwork](https://cloud.google.com/dataflow/docs/guides/specifying-networks#specifying_a_network_and_a_subnetwork) as the **subnetwork**.

See the [official documentation](https://cloud.google.com/dataflow/docs/guides/templates/provided-streaming#text-files-on-cloud-storage-to-bigquery-stream) on how to deploy a Classic Template.

#### Flex Template

When deploying a Flex Template provide values for these optional parameters:

- Set **Use Public Ips** to `false` to [Disabled Public IPs](https://cloud.google.com/dataflow/docs/guides/specifying-networks#public_ip_parameter).
- Set [Enable Streaming Engine](https://cloud.google.com/dataflow/docs/guides/deploying-a-pipeline#streaming-engine) to `true`.
- Use the [storage bucket](#stagingtemp-bucket) created as the **Temp location**.
- Use the [Dataflow KMS Key](#customer-managed-encryption-key) created as the **Dataflow KMS Key**.
- Use the [Dataflow Worker Service Account](#dataflow-worker-service-account) created as the **service account email**.
- Provide your [subnetwork](https://cloud.google.com/dataflow/docs/guides/specifying-networks#specifying_a_network_and_a_subnetwork) as the **subnetwork**.

See the [official documentation](https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates#java_2) on how to deploy a Flex Template.

----------------------

# WORK IN PROGRESS:

### Deploying with `gcloud` Command

**Flex Template** https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates

You can run the following commands to create a **Java** Dataflow Flex Job using the **gcloud command**:

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

For more details about `gcloud dataflow flex-template` see the command [documentation](https://cloud.google.com/sdk/gcloud/reference/dataflow/flex-template/run).

**Classic Template** https://cloud.google.com/dataflow/docs/guides/templates/running-templates#using-gcloud

*********:

```sh

COMMAND

```

For more details about `gcloud dataflow jobs run` see the command [documentation](https://cloud.google.com/sdk/gcloud/reference/dataflow/jobs/run).
