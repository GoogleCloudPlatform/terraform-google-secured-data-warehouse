# Standalone

This examples deploys the *Secured Data Warehouse* blueprint module,
the required "external harness" needed to deploy it,
and Dataflow Pipelines that process sensitive data using the *Secured Data Warehouse* infrastructure.

In the External Harness we have:

- The creation of four GCP projects needed by the *Secured Data Warehouse*:
  - Data Ingestion project.
  - Non-confidential Data project.
  - Data Governance project.
  - Confidential Data project.
- The Creation of an external Artifact Registry project for the dataflow flex templates and the build of the templates themselves, including:
  - A Docker Artifact registry.
  - A Python Artifact registry.
  - A Python Pub/Sub to BigQuery DLP de-identification Dataflow Flex Template.
  - A Python BigQuery to BigQuery DLP re-identification Dataflow Flex Template.
- The Creation of two VPC Networks to deploy Dataflow Pipelines, one in the Data Ingestion project and another one in the Confidential Data project, each network having:
  - A VPC Network with one subnetwork.
  - A set of Firewall rules.
  - The required DNS configuration for Google Private Access.
- The configuration of Log Sinks in all projects with the creation of a related Logging bucket in the Data Governance project
- The Cloud KMS infrastructure for the creation of a `wrapped_key` and `crypto_key` pair:
  - A Cloud KMS Keyring.
  - A Cloud KMS key encryption key (KEK).
  - A token encryption key (TEK) for DLP Templates.

In the deploy of the *Secured Data Warehouse* and the Dataflow Pipelines we have:

- The deploy of the [main module](../../README.md) itself.
- The creation of two Dataflow Pipelines using the same [Dataflow template](../../flex-templates/python/regional_dlp_re_identification/README.md) that can do both de-identification and re-identification using the `wrapped_key` and `crypto_key` pair created in the harness.
- The creation of a Data Catalog taxonomy and [policy tags](https://cloud.google.com/bigquery/docs/best-practices-policy-tags) representing security levels.
- The creation of a BigQuery table with [column-level security](https://cloud.google.com/bigquery/docs/column-level-security) enabled using the Data Catalog policy tags.

The example waits for 10 minutes between the deploy of the de-identification Dataflow Pipeline and the start of the re-identification Dataflow Pipeline,
to wait for the first job to deploy, process the 10k records, and write to the BigQuery table that will be processed by the second job.

The re-identification step is typically a separate deliberated action (with change control) to re-identify and limit
who can read the data but is executed automatically in the example to showcase the BigQuery security controls.

## Google Cloud Locations

This example will be deployed at the `us-east4` location, to deploy in another location,
change the local `location` in the example [main.tf](./main.tf#L18) file.
By default, the *Secured Data Warehouse* module has an [Organization Policy](https://cloud.google.com/resource-manager/docs/organization-policy/defining-locations)
that only allows the creation of resource in `us-locations`.
To deploy in other locations, update the input [trusted_locations](../../README.md#inputs) with
the appropriated location in the call to the [main module](./main.tf#L33).

## Usage

- Copy `tfvars` by running `cp terraform.example.tfvars terraform.tfvars` and update `terraform.tfvars` with values from your environment.
- Run `terraform init`.
- Run `terraform plan` and review the plan.
- Run `terraform apply`.

### Clean up

- Run `terraform destroy` to clean up your environment.

### Perimeter members list

To be able to see the resources protected by the VPC Service Controls [Perimeters](https://cloud.google.com/vpc-service-controls/docs/service-perimeters) in the Google Cloud Console
you need to add your user in the variable `perimeter_additional_members` in the `terraform.tfvars` file.

### Sample Data

The sample data used in this example is a [Public BigQuery Table](https://console.cloud.google.com/bigquery?project=bigquery-public-data&d=irs_990&p=bigquery-public-data&page=table&ws=!1m9!1m3!3m2!1sbigquery-public-data!2sirs_990!1m4!4m3!1sbigquery-public-data!2sirs_990!3sirs_990_ein&t=irs_990_ein).
The data [is a United States Internal Revenue Service form that provides the public with financial information about a nonprofit organization](https://en.wikipedia.org/wiki/Form_990).
For this example, the input query will retrieve 10k records from the public dataset.

Bigquery table spec:

- ein.
- name.
- ico.
- street.
- city.
- state.
- zip.
- group.
- subsection.
- affiliation.
- classification.
- ruling.
- deductibility.
- foundation.
- activity.
- organization.
- status.
- tax_period.
- asset_cd.
- income_cd.
- filing_req_cd.
- pf_filing_req_cd.
- acct_pd.
- asset_amt.
- income_amt.
- revenue_amt.
- ntee_cd.
- sort_name.

The de-identification Dataflow Pipeline will apply these DLP Crypto-based tokenization transformations to encrypt the data:

- [Deterministic encryption](https://cloud.google.com/dlp/docs/transformations-reference#de) Transformation:
  - ein.
  - street.
  - name.
- [Format-preserving encryption](https://cloud.google.com/dlp/docs/transformations-reference#fpe) Transformation:
  - state.

### Taxonomy used

This example creates a Data Catalog taxonomy to enable [BigQuery column-level access controls](https://cloud.google.com/bigquery/docs/column-level-security-intro).

The taxonomy has three level: **Confidential**, **Private**, and **Sensitive** and access to a higher level grants also access to the lower levels

- **3_Confidential:** Most sensitive data classification. Significant damage to enterprise.
  - US_EMPLOYER_IDENTIFICATION_NUMBER.
  - **2_Private:** Data meant to be private. Likely to cause damage to enterprise.
    - PERSON_NAME.
    - STREET_ADDRESS.
    - US_STATE.
    - **1_Sensitive:** Data not meant to be public.
      - INCOME_AMT.
      - REVENUE_AMT.

No user has access to read this data protected with column-level security.
If they need access, the  [Fine-Grained Reader](https://cloud.google.com/bigquery/docs/column-level-security#fine_grained_reader) role needs to be added to the appropriate user or group.

## Requirements

These sections describe requirements for running this example.

### Software

Install the following dependencies:

- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 357.0.0 or later.
- [Terraform](https://www.terraform.io/downloads.html) version 0.13.7 or later.
- [curl](https://curl.haxx.se/) version 7.68.0 or later.

### Cloud SDK configurations

Acquire your user credentials to use for **Application Default Credentials**:

```sh
gcloud auth application-default login
```

Unset the project in the core section to avoid errors in the deploy with deleted or unavailable projects, and billings on inappropriate projects:

```sh
gcloud config unset project
```

### Service Account

To provision the resources of this example, create a privileged service account,
where the service account key cannot be created.
In addition, consider using Cloud Monitoring to alert on this service account's activity.
Grant the following roles to the service account.

- Organization level:
  - Access Context Manager Admin: `roles/accesscontextmanager.policyAdmin`
  - Billing Account User: `roles/billing.user`
  - Organization Policy Administrator: `roles/orgpolicy.policyAdmin`
  - Organization Administrator: `roles/resourcemanager.organizationAdmin`
- Folder Level:
  - Compute Network Admin: `roles/compute.networkAdmin`
  - Logging Admin: `roles/logging.admin`
  - Project Creator: `roles/resourcemanager.projectCreator`
  - Project Deleter: `roles/resourcemanager.projectDeleter`
  - Project IAM Admin: `roles/resourcemanager.projectIamAdmin`
  - Service Usage Admin: `roles/serviceusage.serviceUsageAdmin`

As an alternative to granting the service account the `Billing Account User` role in organization,
it is possible to grant it [directly in the billing account](https://cloud.google.com/billing/docs/how-to/billing-access#update-cloud-billing-permissions).

You can run the following `gcloud` command to assign `Billing Account User` role to the service account.

```sh
export SA_EMAIL=<YOUR-SA-EMAIL>
export BILLING_ACCOUNT=<YOUR-BILLING-ACCOUNT>

gcloud beta billing accounts add-iam-policy-binding "${BILLING_ACCOUNT}" \
--member="serviceAccount:${SA_EMAIL}" \
--role="roles/billing.user"
```

You can use the [Project Factory module](https://github.com/terraform-google-modules/terraform-google-project-factory) and the
[IAM module](https://github.com/terraform-google-modules/terraform-google-iam) in combination to provision a
service account with the necessary roles applied.

The user using this service account must have the necessary roles, `Service Account User` and `Service Account Token Creator`, to [impersonate](https://cloud.google.com/iam/docs/impersonating-service-accounts) the service account.

You can run the following commands to assign roles to the service account:

```sh
export ORG_ID=<YOUR-ORG-ID>
export FOLDER_ID=<YOUR-FOLDER-ID>
export SA_EMAIL=<YOUR-SA-EMAIL>

gcloud organizations add-iam-policy-binding ${ORG_ID} \
--member="serviceAccount:${SA_EMAIL}" \
--role="roles/accesscontextmanager.policyAdmin"

gcloud organizations add-iam-policy-binding ${ORG_ID} \
--member="serviceAccount:${SA_EMAIL}" \
--role="roles/billing.user"

gcloud organizations add-iam-policy-binding ${ORG_ID} \
--member="serviceAccount:${SA_EMAIL}" \
--role="roles/orgpolicy.policyAdmin"

gcloud resource-manager folders \
add-iam-policy-binding ${FOLDER_ID} \
--member="serviceAccount:${SA_EMAIL}" \
--role="roles/compute.networkAdmin"

gcloud resource-manager folders \
add-iam-policy-binding ${FOLDER_ID} \
--member="serviceAccount:${SA_EMAIL}" \
--role="roles/logging.admin"

gcloud resource-manager folders \
add-iam-policy-binding ${FOLDER_ID} \
--member="serviceAccount:${SA_EMAIL}" \
--role="roles/resourcemanager.projectCreator"

gcloud resource-manager folders \
add-iam-policy-binding ${FOLDER_ID} \
--member="serviceAccount:${SA_EMAIL}" \
--role="roles/resourcemanager.projectDeleter"

gcloud resource-manager folders \
add-iam-policy-binding ${FOLDER_ID} \
--member="serviceAccount:${SA_EMAIL}" \
--role="roles/resourcemanager.projectIamAdmin"

gcloud resource-manager folders \
add-iam-policy-binding ${FOLDER_ID} \
--member="serviceAccount:${SA_EMAIL}" \
--role="roles/serviceusage.serviceUsageAdmin"
```

### APIs

The following APIs must be enabled in the project where the service account was created:

- Access Context Manager API: `accesscontextmanager.googleapis.com`
- App Engine Admin API: `appengine.googleapis.com`
- Cloud Billing API: `cloudbilling.googleapis.com`
- Cloud Build API: `cloudbuild.googleapis.com`
- Cloud Key Management Service (KMS) API: `cloudkms.googleapis.com`
- Cloud Pub/Sub API: `pubsub.googleapis.com`
- Cloud Resource Manager API: `cloudresourcemanager.googleapis.com`
- Compute Engine API: `compute.googleapis.com`
- Dataflow API: `dataflow.googleapis.com`
- Identity and Access Management (IAM) API: `iam.googleapis.com`
- BigQuery API: `bigquery.googleapis.com`

You can run the following `gcloud` command to enable these APIs in the service account project.

```sh
export PROJECT_ID=<SA-PROJECT-ID>

gcloud services enable \
accesscontextmanager.googleapis.com \
appengine.googleapis.com \
bigquery.googleapis.com \
cloudbilling.googleapis.com \
cloudbuild.googleapis.com \
cloudkms.googleapis.com \
pubsub.googleapis.com \
cloudresourcemanager.googleapis.com \
compute.googleapis.com \
dataflow.googleapis.com \
iam.googleapis.com \
--project ${PROJECT_ID}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `string` | `""` | no |
| billing\_account | The billing account id associated with the projects, e.g. XXXXXX-YYYYYY-ZZZZZZ. | `any` | n/a | yes |
| data\_analyst\_group | Google Cloud IAM group that analyzes the data in the warehouse. | `string` | n/a | yes |
| data\_engineer\_group | Google Cloud IAM group that sets up and maintains the data pipeline and warehouse. | `string` | n/a | yes |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| folder\_id | The folder to deploy in. | `any` | n/a | yes |
| kms\_key\_protection\_level | (Optional) The protection level to use when creating a key. Possible values: ["SOFTWARE", "HSM"] | `string` | `"HSM"` | no |
| network\_administrator\_group | Google Cloud IAM group that reviews network configuration. Typically, this includes members of the networking team. | `string` | n/a | yes |
| org\_id | The numeric organization id. | `any` | n/a | yes |
| perimeter\_additional\_members | The list of members to be added on perimeter access. To be able to see the resources protected by the VPC Service Controls add your user must be in this list. The service accounts created by this module do not need to be added to this list. Entries must be in the standard GCP form: `user:email@email.com` or `serviceAccount:my-service-account@email.com`. | `list(string)` | n/a | yes |
| security\_administrator\_group | Google Cloud IAM group that administers security configurations in the organization(org policies, KMS, VPC service perimeter). | `string` | n/a | yes |
| security\_analyst\_group | Google Cloud IAM group that monitors and responds to security incidents. | `string` | n/a | yes |
| terraform\_service\_account | The email address of the service account that will run the Terraform code. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| confidential\_dataflow\_controller\_service\_account\_email | The confidential project Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account. |
| data\_ingestion\_bucket\_name | The name of the bucket created for data ingestion pipeline. |
| data\_ingestion\_topic\_name | The topic created for data ingestion pipeline. |
| dataflow\_controller\_service\_account\_email | The data ingestion project Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account. |
| pubsub\_writer\_service\_account\_email | The PubSub writer service account email. Should be used to write data to the PubSub topics the data ingestion pipeline reads from. |
| storage\_writer\_service\_account\_email | The Storage writer service account email. Should be used to write data to the buckets the data ingestion pipeline reads from. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
