# Secured Data Warehouse Blueprint

This repository contains Terraform configuration modules that allow Google Cloud customers to
quickly deploy a secured [BigQuery](https://cloud.google.com/bigquery) data warehouse. The blueprint allows customers
to use Google Cloud's core strengths in data analytics, and to overcome typical
challenges that include:

- Limited knowledge/experience with best practices for creating, deploying, and operating in Google
Cloud.
- Security/risk concerns and restrictions from their internal security, risk, and compliance teams.
- Regulatory and compliance approval from external auditors.

The Terraform configurations in this repository provide customers with an opinionated architecture
that incorporates and documents best practices for a performant and scalable design, combined with
security by default for control, logging and evidence generation. It can be  simply deployed by
customers through a Terraform workflow.

## Usage

Basic usage of this module is as follows:

```hcl
module "secured_data_warehouse" {
  source  = "terraform-google-modules/secured-data-warehouse/google"
  version = "~> 0.1"

  org_id                           = ORG_ID
  data_governance_project_id       = DATA_GOVERNANCE_PROJECT_ID
  confidential_data_project_id     = CONFIDENTIAL_DATA_PROJECT_ID
  datalake_project_id              = DATALAKE_PROJECT_ID
  data_ingestion_project_id        = DATA_INGESTION_PROJECT_ID
  sdx_project_number               = EXTERNAL_TEMPLATE_PROJECT_NUMBER
  terraform_service_account        = TERRAFORM_SERVICE_ACCOUNT
  access_context_manager_policy_id = ACCESS_CONTEXT_MANAGER_POLICY_ID
  bucket_name                      = DATA_INGESTION_BUCKET_NAME
  location                         = LOCATION
  dataset_id                       = DATASET_ID
  confidential_dataset_id          = CONFIDENTIAL_DATASET_ID
  cmek_keyring_name                = CMEK_KEYRING_NAME
  delete_contents_on_destroy       = false
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `number` | n/a | yes |
| bucket\_class | The storage class for the bucket being provisioned. | `string` | `"STANDARD"` | no |
| bucket\_lifecycle\_rules | List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches\_storage\_class should be a comma delimited string. | <pre>set(object({<br>    action    = any<br>    condition = any<br>  }))</pre> | <pre>[<br>  {<br>    "action": {<br>      "type": "Delete"<br>    },<br>    "condition": {<br>      "age": 30,<br>      "matches_storage_class": [<br>        "STANDARD"<br>      ],<br>      "with_state": "ANY"<br>    }<br>  }<br>]</pre> | no |
| bucket\_name | The name of for the bucket being provisioned. | `string` | n/a | yes |
| cmek\_keyring\_name | The Keyring name for the KMS Customer Managed Encryption Keys being provisioned. | `string` | n/a | yes |
| confidential\_access\_members | List of members in the standard GCP form: user:{email}, serviceAccount:{email}, group:{email} who will have access to confidential information in BigQuery. | `list(string)` | `[]` | no |
| confidential\_data\_dataflow\_deployer\_identities | List of members in the standard GCP form: user:{email}, serviceAccount:{email} that will deploy Dataflow jobs in the Confidential Data project. These identities will be added to the VPC-SC secure data exchange egress rules. | `list(string)` | `[]` | no |
| confidential\_data\_project\_id | Project where the confidential datasets and tables are created. | `string` | n/a | yes |
| confidential\_dataset\_default\_table\_expiration\_ms | TTL of tables using the dataset in MS. The default value is null. | `number` | `null` | no |
| confidential\_dataset\_id | Unique ID for the confidential dataset being provisioned. | `string` | `"secured_dataset"` | no |
| data\_governance\_project\_id | The ID of the project in which the data governance resources will be created. | `string` | n/a | yes |
| data\_ingestion\_dataflow\_deployer\_identities | List of members in the standard GCP form: user:{email}, serviceAccount:{email} that will deploy Dataflow jobs in the Data Ingestion project. These identities will be added to the VPC-SC secure data exchange egress rules. | `list(string)` | `[]` | no |
| data\_ingestion\_project\_id | The ID of the project in which the data ingestion resources will be created | `string` | n/a | yes |
| datalake\_project\_id | The ID of the project in which the Bigquery will be created. | `string` | n/a | yes |
| dataset\_default\_table\_expiration\_ms | TTL of tables using the dataset in MS. The default value is null. | `number` | `null` | no |
| dataset\_description | Dataset description. | `string` | `"Ingest dataset"` | no |
| dataset\_id | Unique ID for the dataset being provisioned. | `string` | n/a | yes |
| dataset\_name | Friendly name for the dataset being provisioned. | `string` | `"Ingest dataset"` | no |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| key\_rotation\_period\_seconds | Rotation period for keys. The default value is 30 days. | `string` | `"2592000s"` | no |
| location | The location for the KMS Customer Managed Encryption Keys, Bucket, and Bigquery dataset. This location can be a multiregion, if it is empty the region value will be used. | `string` | `""` | no |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_additional\_members | The list additional members to be added on perimeter access. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required. | `list(string)` | `[]` | no |
| private\_access\_members | List of members in the standard GCP form: user:{email}, serviceAccount:{email}, group:{email} who will have access to private information in BigQuery. | `list(string)` | `[]` | no |
| region | The region in which the resources will be deployed. | `string` | `"us-east4"` | no |
| sdx\_project\_number | The Project Number to configure Secure data exchange with egress rule for the dataflow templates. | `string` | n/a | yes |
| terraform\_service\_account | The email address of the service account that will run the Terraform code. | `string` | n/a | yes |
| trusted\_locations | This is a list of trusted regions where location-based GCP resources can be created. ie us-locations eu-locations. | `list(string)` | <pre>[<br>  "us-locations",<br>  "eu-locations"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| cmek\_bigquery\_crypto\_key | The Customer Managed Crypto Key for the BigQuery service. |
| cmek\_confidential\_bigquery\_crypto\_key | The Customer Managed Crypto Key for the confidential BigQuery service. |
| cmek\_ingestion\_crypto\_key | The Customer Managed Crypto Key for the Ingestion crypto boundary. |
| cmek\_reidentification\_crypto\_key | The Customer Managed Crypto Key for the Confidential crypto boundary. |
| confidential\_access\_level\_name | Access context manager access level name. |
| confidential\_data\_dataflow\_bucket\_name | The name of the bucket created for dataflow in the confidential data pipeline. |
| confidential\_dataflow\_controller\_service\_account\_email | The confidential Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account. |
| confidential\_service\_perimeter\_name | Access context manager service perimeter name. |
| data\_governance\_access\_level\_name | Access context manager access level name. |
| data\_governance\_service\_perimeter\_name | Access context manager service perimeter name. |
| data\_ingest\_bigquery\_dataset | The bigquery dataset created for data ingest pipeline. |
| data\_ingest\_bucket\_name | The name of the bucket created for data ingest pipeline. |
| data\_ingest\_dataflow\_bucket\_name | The name of the bucket created for dataflow in the data ingest pipeline. |
| data\_ingest\_topic\_name | The topic created for data ingest pipeline. |
| data\_ingestion\_access\_level\_name | Access context manager access level name. |
| data\_ingestion\_service\_perimeter\_name | Access context manager service perimeter name. |
| dataflow\_controller\_service\_account\_email | The Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account. |
| pubsub\_writer\_service\_account\_email | The PubSub writer service account email. Should be used to write data to the PubSub topics the ingestion pipeline reads from. |
| storage\_writer\_service\_account\_email | The Storage writer service account email. Should be used to write data to the buckets the ingestion pipeline reads from. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

Install the following dependencies:

- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 357.0.0 or later
- [Terraform](https://www.terraform.io/downloads.html) version 0.13.7 or later
- [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) version 3.67 or later
- [Terraform Provider for GCP Beta](https://github.com/terraform-providers/terraform-provider-google-beta) version 3.67 or later

### Service Account

To provision the resources of this module, create a service account
with the following IAM roles:

- Project level:
  - App Engine Creator:`roles/appengine.appCreator`
  - Artifact Registry Administrator:`roles/artifactregistry.admin`
  - BigQuery Admin:`roles/bigquery.admin`
  - Browser:`roles/browser`
  - Cloud Build Editor:`roles/cloudbuild.builds.editor`
  - Cloud KMS Admin:`roles/cloudkms.admin`
  - Cloud KMS CryptoKey Encrypter:`roles/cloudkms.cryptoKeyEncrypter`
  - Cloud Scheduler Admin:`roles/cloudscheduler.admin`
  - Compute Network Admin:`roles/compute.networkAdmin`
  - Compute Security Admin:`roles/compute.securityAdmin`
  - Create Service Accounts:`roles/iam.serviceAccountCreator`
  - DLP De-identify Templates Editor:`roles/dlp.deidentifyTemplatesEditor`
  - DLP Inspect Templates Editor:`roles/dlp.inspectTemplatesEditor`
  - DLP User:`roles/dlp.user`
  - DNS Administrator:`roles/dns.admin`
  - Data Catalog Admin:`roles/datacatalog.admin`
  - Dataflow Developer:`roles/dataflow.developer`
  - Delete Service Accounts:`roles/iam.serviceAccountDeleter`
  - Project IAM Admin:`roles/resourcemanager.projectIamAdmin`
  - Pub/Sub Admin:`roles/pubsub.admin`
  - Service Account Token Creator:`roles/iam.serviceAccountTokenCreator`
  - Service Account User:`roles/iam.serviceAccountUser`
  - Storage Admin:`roles/storage.admin`
- Organization level
  - Access Context Manager Admin: `roles/accesscontextmanager.policyAdmin`
  - Billing User: `roles/billing.user`
  - Organization Administrator: `roles/resourcemanager.organizationAdmin`
  - Organization Policy Administrator: `roles/orgpolicy.policyAdmin`
  - Organization Shared VPC Admin: `roles/compute.xpnAdmin`
  - VPC Access Admin: `roles/vpcaccess.admin`

You can use the [Project Factory module][project-factory-module] and the
[IAM module][iam-module] in combination to provision a
service account with the necessary roles applied.

The user using this service account must have the necessary roles to [impersonate](https://cloud.google.com/iam/docs/impersonating-service-accounts) the service account.

### APIs

Create four projects with the following APIs enabled to host the
resources of this module:

#### Data ingestion project

- Access Context Manager API: `accesscontextmanager.googleapis.com`
- App Engine Admin API:`appengine.googleapis.com`
- Artifact Registry API:`artifactregistry.googleapis.com`
- BigQuery API:`bigquery.googleapis.com`
- Cloud Billing API:`cloudbilling.googleapis.com`
- Cloud Build API:`cloudbuild.googleapis.com`
- Cloud Key Management Service (KMS) API:`cloudkms.googleapis.com`
- Cloud Resource Manager API:`cloudresourcemanager.googleapis.com`
- Cloud Scheduler API:`cloudscheduler.googleapis.com`
- Compute Engine API:`compute.googleapis.com`
- Google Cloud Data Catalog API:`datacatalog.googleapis.com`
- Dataflow API:`dataflow.googleapis.com`
- Cloud Data Loss Prevention (DLP) API:`dlp.googleapis.com`
- Cloud DNS API:`dns.googleapis.com`
- Identity and Access Management (IAM) API:`iam.googleapis.com`
- Cloud Pub/Sub API:`pubsub.googleapis.com`
- Service Usage API:`serviceusage.googleapis.com`
- Google Cloud Storage JSON API:`storage-api.googleapis.com`

#### Data governance project

- Access Context Manager API: `accesscontextmanager.googleapis.com`
- Cloud Billing API:`cloudbilling.googleapis.com`
- Cloud Key Management Service (KMS) API:`cloudkms.googleapis.com`
- Cloud Resource Manager API:`cloudresourcemanager.googleapis.com`
- Google Cloud Data Catalog API:`datacatalog.googleapis.com`
- Cloud Data Loss Prevention (DLP) API:`dlp.googleapis.com`
- Identity and Access Management (IAM) API:`iam.googleapis.com`
- Service Usage API:`serviceusage.googleapis.com`
- Google Cloud Storage JSON API:`storage-api.googleapis.com`

#### Data lake project

- Access Context Manager API: `accesscontextmanager.googleapis.com`
- BigQuery API:`bigquery.googleapis.com`
- Cloud Billing API:`cloudbilling.googleapis.com`
- Cloud Key Management Service (KMS) API:`cloudkms.googleapis.com`
- Cloud Resource Manager API:`cloudresourcemanager.googleapis.com`
- Identity and Access Management (IAM) API:`iam.googleapis.com`
- Service Usage API:`serviceusage.googleapis.com`
- Google Cloud Storage JSON API:`storage-api.googleapis.com`

#### Confidential data project

- Access Context Manager API: `accesscontextmanager.googleapis.com`
- Google Cloud Storage JSON API: `storage-api.googleapis.com`
- Artifact Registry API:`artifactregistry.googleapis.com`
- BigQuery API:`bigquery.googleapis.com`
- Cloud Billing API:`cloudbilling.googleapis.com`
- Cloud Build API:`cloudbuild.googleapis.com`
- Cloud Key Management Service (KMS) API:`cloudkms.googleapis.com`
- Cloud Resource Manager API:`cloudresourcemanager.googleapis.com`
- Compute Engine API:`compute.googleapis.com`
- Google Cloud Data Catalog API:`datacatalog.googleapis.com`
- Dataflow API:`dataflow.googleapis.com`
- Cloud Data Loss Prevention (DLP) API:`dlp.googleapis.com`
- Cloud DNS API:`dns.googleapis.com`
- Identity and Access Management (IAM) API:`iam.googleapis.com`
- Service Usage API:`serviceusage.googleapis.com`
- Google Cloud Storage JSON API:`storage-api.googleapis.com`

You can use he [Project Factory module][project-factory-module] to
provision the projects with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

---
This is not an officially supported Google product
