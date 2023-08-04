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

[Custom names](#inputs) can be provided for the five projects created in this example.
If custom names are not provided, the names of the projects will be:

- `ext-harness`
- `sdw-data-ing`
- `sdw-data-gov`
- `sdw-non-conf`
- `sdw-conf`

A random suffix will be added to the end of the names to create the project ID to prevent collisions with existing projects.

In the deploy of the *Secured Data Warehouse* and the Dataflow Pipelines we have:

- The deploy of the [main module](../../README.md) itself.
- The creation of two Dataflow Pipelines using the same [Dataflow template](../../flex-templates/python/regional_dlp_re_identification/README.md) that can do both de-identification and re-identification using the `wrapped_key` and `crypto_key` pair created in the harness.
- The creation of a Data Catalog taxonomy and [policy tags](https://cloud.google.com/bigquery/docs/best-practices-policy-tags) representing security levels.
- The creation of a BigQuery table with [column-level security](https://cloud.google.com/bigquery/docs/column-level-security) enabled using the Data Catalog policy tags.

The example waits for 10 minutes between the deploy of the de-identification Dataflow Pipeline and the start of the re-identification Dataflow Pipeline,
to wait for the first job to deploy, process the 10k records, and write to the BigQuery table that will be processed by the second job.

The re-identification step is typically a separate deliberated action (with change control) to re-identify and limit
who can read the data but is executed automatically in the example to showcase the BigQuery security controls.

**Note:** To deploy this example it is also necessary to have *an existing project* on which the [Service Account](#service-account)
used to deploy this example needs to be created and have the required IAM Roles granted to it.
This project should not be on the same folder used to deploy the *Secured Data Warehouse*  in accordance with the separation of concerns principle.
You can use the [Project Factory module](https://github.com/terraform-google-modules/terraform-google-project-factory) and the
[IAM module](https://github.com/terraform-google-modules/terraform-google-iam) in combination to provision a
service account with the necessary roles applied.


## Google Cloud Locations

This example will be deployed at the `us-east4` location, to deploy in another location,
change the local `location` in the example [main.tf](./main.tf#L18) file.
By default, the *Secured Data Warehouse* module has an [Organization Policy](https://cloud.google.com/resource-manager/docs/organization-policy/defining-locations)
that only allows the creation of resource in `us-locations`.
To deploy in other locations, update the input [trusted_locations](../../README.md#inputs) with
the appropriated location in the call to the [main module](./main.tf#L33).

## Usage

- Rename the `tfvars` file by running `mv terraform.example.tfvars terraform.tfvars` and update `terraform.tfvars` with values from your environment.

  ```bash
  mv terraform.example.tfvars terraform.tfvars
  ```

- Run `terraform init` to get the plugins.

  ```bash
  terraform init
  ```

- Run `terraform plan` and review the plan.

  ```bash
  terraform plan
  ```

- Run `terraform apply` to apply the infrastructure build.

  ```bash
  terraform apply
  ```


### Clean up

- Run `terraform destroy` to clean up your environment.
The input `delete_contents_on_destroy` must have been set to `true` in the original `apply` for the `terraform destroy` command to work.

  ```bash
  terraform destroy
  ```

### Perimeter members list

To be able to see the resources protected by the VPC Service Controls [Perimeters](https://cloud.google.com/vpc-service-controls/docs/service-perimeters) in the Google Cloud Console
you need to add your user in the variable `perimeter_additional_members` in the `terraform.tfvars` file.

### Sample Data

The sample data used in this example is a Public BigQuery Table that belongs to the [IRS 990 public dataset](https://console.cloud.google.com/marketplace/product/internal-revenue-service/irs-990?project=bigquery-public-data).

The de-identification Dataflow Pipeline will apply these DLP Crypto-based tokenization transformations to encrypt the data:

- [Deterministic encryption](https://cloud.google.com/dlp/docs/transformations-reference#de) Transformation:
  - ein.
  - street.
  - name.
- [Format-preserving encryption](https://cloud.google.com/dlp/docs/transformations-reference#fpe) Transformation:
  - state.

### Taxonomy used

This example creates a Data Catalog taxonomy to enable [BigQuery column-level access controls](https://cloud.google.com/bigquery/docs/column-level-security-intro).

The taxonomy has four levels: **Confidential**, **Private**, **Sensitive**, and **Public** and access to a higher level grants also access to the lower levels

- **4_Confidential:** Most sensitive data classification. Significant damage to enterprise.
  - US_EMPLOYER_IDENTIFICATION_NUMBER.
  - **3_Private:** Data meant to be private. Likely to cause damage to enterprise.
    - PERSON_NAME.
    - STREET_ADDRESS.
    - US_STATE.
    - **2_Sensitive:** Data not meant to be public.
      - INCOME_AMT.
      - REVENUE_AMT.
      - **1_Public:** Data is freely accessible to the public.
        - Not tagged fields.

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

The standalone example uses a python script to generate the [wrapped_key](../../helpers/wrapped-key/README.md) that will be used in the DLP template to encrypt and decrypt the information. This script will run using the [Application Default Credentials](https://cloud.google.com/sdk/gcloud/reference/auth/application-default).

So it is important to guarantee that the **Application Default Credentials** are correctly configured, to acquire yours:

```sh
gcloud auth application-default login
```

To avoid errors in the deployment, you must also guarantee that the `gcloud command` is not using a project that has been deleted or is unavailable.
We recommend to unset the project:

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
--role="roles/resourcemanager.organizationAdmin"

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

**Note:** The script `wrapped_key.sh` will grant the  `cloudkms.cryptoOperator` role for the Terraform Service Account during the KMS `wrapped_key` creation. This role provides permission for the `wrapped_key.sh` script to use the [Generate Random Bytes](https://cloud.google.com/kms/docs/generate-random#kms-generate-random-bytes-python) functionality which is necessary to generate the token that will be used in the KMS `wrapped_key`. The `cloudkms.cryptoOperator` role will be removed from the Terraform Service Account once the KMS `wrapped_key` has been created.

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

### Outputs by personas

These outputs can be interesting for all user:

- Blueprint type
- Data ingestion dataflow bucket name
- Confidential data project id
- Data governance project id
- Data ingestion project id
- Non-confidential data project id
- Service account: dataflow controller service account

These outputs can be interesting for data analyst group:

- Bigquery non confidential table
- Bigquery confidential table
- Confidential data project id
- Non-confidential data project id
- Data ingestion dataflow bucket name
- Taxonomy

These outputs can be interesting for data engineer group:

- Data ingestion topic name
- Pubsub writer service account email
- Storage writer service account email
- Tek wrapping keyring

These outputs can be interesting for network administrator group:

- Confidential network name
- Confidential network self link
- Confidential subnets self link
- Data ingestion network name
- Data ingestion network self link
- Data ingestion subnets self link

These outputs can be interesting for security administrator group:

- Cmek bigquery crypto key
- Cmek confidential bigquery crypto key
- Cmek data ingestion crypto key
- Cmek reidentification crypto key
- Confidential data perimeter name
- Data governance perimeter name
- Data ingestion service perimeter name
- Tek wrapping keyring

These outputs can be interesting for security analyst group:

- Centralized logging bucket name
- Taxonomy display name

### Troubleshooting

If you encounter problems in the apply execution check the [Troubleshooting Guide](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/blob/main/docs/TROUBLESHOOTING.md).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `string` | n/a | yes |
| billing\_account | The billing account id associated with the projects, e.g. XXXXXX-YYYYYY-ZZZZZZ. | `string` | n/a | yes |
| confidential\_data\_project\_name | Custom project name for the confidential data project. | `string` | `""` | no |
| data\_analyst\_group | Google Cloud IAM group that analyzes the data in the warehouse. | `string` | n/a | yes |
| data\_engineer\_group | Google Cloud IAM group that sets up and maintains the data pipeline and warehouse. | `string` | n/a | yes |
| data\_governance\_project\_name | Custom project name for the data governance project. | `string` | `""` | no |
| data\_ingestion\_project\_name | Custom project name for the data ingestion project. | `string` | `""` | no |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| folder\_id | The folder to deploy in. | `string` | n/a | yes |
| network\_administrator\_group | Google Cloud IAM group that reviews network configuration. Typically, this includes members of the networking team. | `string` | n/a | yes |
| non\_confidential\_data\_project\_name | Custom project name for the non confidential data project. | `string` | `""` | no |
| org\_id | The numeric organization id. | `string` | n/a | yes |
| perimeter\_additional\_members | The list of members to be added on perimeter access. To be able to see the resources protected by the VPC Service Controls add your user must be in this list. The service accounts created by this module do not need to be added to this list. Entries must be in the standard GCP form: `user:email@email.com` or `serviceAccount:my-service-account@email.com`. | `list(string)` | n/a | yes |
| security\_administrator\_group | Google Cloud IAM group that administers security configurations in the organization(org policies, KMS, VPC service perimeter). | `string` | n/a | yes |
| security\_analyst\_group | Google Cloud IAM group that monitors and responds to security incidents. | `string` | n/a | yes |
| template\_project\_name | Custom project name for the template project. | `string` | `""` | no |
| terraform\_service\_account | The email address of the service account that will run the Terraform code. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bigquery\_confidential\_table | The bigquery table created for the confidential project. |
| bigquery\_non\_confidential\_table | The bigquery table created for the non confidential project. |
| blueprint\_type | Type of blueprint this module represents. |
| centralized\_logging\_bucket\_name | The name of the bucket created for storage logging. |
| cmek\_bigquery\_crypto\_key | The Customer Managed Crypto Key for the BigQuery service. |
| cmek\_confidential\_bigquery\_crypto\_key | The Customer Managed Crypto Key for the confidential BigQuery service. |
| cmek\_data\_ingestion\_crypto\_key | The Customer Managed Crypto Key for the data ingestion crypto boundary. |
| cmek\_reidentification\_crypto\_key | The Customer Managed Crypto Key for the reidentification crypto boundary. |
| confidential\_data\_dataflow\_bucket\_name | The name of the bucket created for dataflow in the confidential data pipeline. |
| confidential\_data\_perimeter\_name | Access context manager service perimeter name. |
| confidential\_data\_project\_id | The ID of the project created for confidential datasets and tables. |
| confidential\_network\_name | The name of the confidential VPC being created. |
| confidential\_network\_self\_link | The URI of the confidential VPC being created. |
| confidential\_subnets\_self\_link | The self-links of confidential subnets being created. |
| data\_governance\_perimeter\_name | Access context manager service perimeter name. |
| data\_governance\_project\_id | The ID of the project created for data governance. |
| data\_ingestion\_dataflow\_bucket\_name | The name of the bucket created for dataflow in the data ingestion pipeline. |
| data\_ingestion\_network\_name | The name of the data ingestion VPC being created. |
| data\_ingestion\_network\_self\_link | The URI of the data ingestion VPC being created. |
| data\_ingestion\_project\_id | The ID of the project created for the data ingstion pipeline. |
| data\_ingestion\_service\_perimeter\_name | Access context manager service perimeter name. |
| data\_ingestion\_subnets\_self\_link | The self-links of data ingestion subnets being created. |
| data\_ingestion\_topic\_name | The topic created for data ingestion pipeline. |
| dataflow\_controller\_service\_account\_email | The regional de identification pipeline service account. |
| non\_confidential\_data\_project\_id | The id of the project created for non-confidential data. |
| pubsub\_writer\_service\_account\_email | The PubSub writer service account email. Should be used to write data to the PubSub topics the data ingestion pipeline reads from. |
| regional\_deid\_pipeline\_job\_id | The unique ID of this job. |
| regional\_reid\_pipeline\_job\_id | The unique ID of this job. |
| storage\_writer\_service\_account\_email | The Storage writer service account email. Should be used to write data to the buckets the data ingestion pipeline reads from. |
| taxonomy\_display\_name | The name of the taxonomy. |
| tek\_wrapping\_keyring | The name of tek wrapping key |
| template\_project\_id | The id of the flex template created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
