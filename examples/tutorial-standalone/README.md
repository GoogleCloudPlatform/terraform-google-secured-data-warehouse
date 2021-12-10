# Standalone Tutorial

This examples deploys the Secured data warehouse blueprint and the required infrastructure needed to deploy it.

The required infrastructure created in this example includes:

- GCP Projects:
  - Data Ingestion project.
  - Non-confidential Data project.
  - Data Governance project.
  - Confidential Data project.
  - External Artifact Registry project.
- Artifact Registry:
  - Docker Artifact registry.
- Dataflow Templates:
  - Java Cloud storage to Bigquery dlp de-identification Dataflow flex template.
  - Java Bigquery to Bigquery dlp re-identification Dataflow flex template.
- Networks:
  - Data Ingestion Network:
    - VPC with one subnetwork.
    - Firewall rules.
    - DNS configuration for Google private access.
  - Confidential Data Network:
    - VPC with one subnetwork.
    - Firewall rules.
    - DNS configuration for Google private access.
- Logging:
  - Log Sinks in all projects.
  - Logging bucket in the data governance project.
- Cloud KMS:
  - A Cloud KMS Keyring.
  - A Cloud KMS key encryption key (KEK).
  - A token encryption key (TEK) for DLP Templates.

This example will be deployed at the `us-east4` location, to deploy in another location, change the local `location` in the example [main.tf](./main.tf#L18) file.

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

### Sample data

The sample data used in this example is a [csv file](./assets/cc_10000_records.csv) with fake credit card data.
For this example, the input file has 10k records.

Each record has these values:

- Card Type Code.
- Card Type Full Name.
- Issuing Bank.
- Card Number.
- Card Holder's Name.
- CVV/CVV2.
- Issue Date.
- Expiry Date.
- Billing Date.
- Card PIN.
- Credit Limit.

The de-identification Dataflow job will apply these DLP Crypto-based tokenization transformations to encrypt the data:

- [Deterministic encryption](https://cloud.google.com/dlp/docs/transformations-reference#de) Transformation:
  - Card Number.
  - Card Holder's Name.
  - CVV/CVV2.
  - Expiry Date.
- [Cryptographic hashing](https://cloud.google.com/dlp/docs/transformations-reference#crypto-hashing) Transformation:
  - Card PIN.

### Generate sample credit card .csv file

You can create new csv files with different sizes using the [sample-cc-generator](../../helpers/sample-cc-generator/README.md) helper.
This new file must be placed in the [assets folder](./assets)
You need to change the value of the local `cc_file_name` in the [main.tf](./main.tf#L25) file to use the new sample file:

```hcl
locals {
  ...
  cc_file_name = "cc_10000_records.csv"
  ...
```

### Taxonomy used

This example creates a Data Catalog taxonomy to enable [BigQuery column-level access controls](https://cloud.google.com/bigquery/docs/column-level-security-intro).

The taxonomy has three level: **Confidential**, **Private**, and **Sensitive** and access to a higher level grants also access to the lower levels

- **3_Confidential:** Most sensitive data classification. Significant damage to enterprise.
  - CREDIT_CARD_NUMBER.
  - CARD_VERIFICATION_VALUE.
  - **2_Private:** Data meant to be private. Likely to cause damage to enterprise.
    - PERSON_NAME.
    - CREDIT_CARD_PIN.
    - CARD_EXPIRY_DATE.
    - **1_Sensitive:** Data not meant to be public.
      - CREDIT_LIMIT.

No user has access to read this data protected with column-level security.
If they need access, the  [Fine-Grained Reader](https://cloud.google.com/bigquery/docs/column-level-security#fine_grained_reader) role needs to be added to the appropriate user or group.

## Requirements

These sections describe requirements for running this example.

### Software

Install the following dependencies:

- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 357.0.0 or later.
- [Terraform](https://www.terraform.io/downloads.html) version 0.13.7 or later.
- [curl](https://curl.haxx.se/) version 7.68.0 or later.

### Service Account

To provision the resources of this example, create a privileged service account,
where the service account key cannot be created.
In addition, consider using Cloud Monitoring to alert on this service account's activity.
Grant the following roles to the service account.

- Organization level:
  - Access Context Manager Admin: `roles/accesscontextmanager.policyAdmin`
  - Billing Account User: `roles/billing.user`
  - Organization Policy Administrator: `roles/orgpolicy.policyAdmin`
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
| kms\_key\_protection\_level | The protection level to use when creating a key. Possible values: ["SOFTWARE", "HSM"] | `string` | `"HSM"` | no |
| network\_administrator\_group | Google Cloud IAM group that reviews network configuration. Typically, this includes members of the networking team. | `string` | n/a | yes |
| org\_id | The numeric organization id. | `any` | n/a | yes |
| perimeter\_additional\_members | The list of all members to be added on perimeter access, except the service accounts created by this module. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required. | `list(string)` | n/a | yes |
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
