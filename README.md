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

  org_id = ORG_ID
  project_id = PROJECT_ID
  region = "us-central1"
  terraform_service_account = TERRAFORM_SERVICE_ACCOUNT
  vpc_name = VPC_NAME
  subnet_ip = "10.0.32.0/21"
  access_context_manager_policy_id = ACCESS_CONTEXT_MANAGER_POLICY_ID
  bucket_name = DATA_INGESTION_BUCKET_NAME
  dataset_id = DATASET_ID
  cmek_keyring_name = CMEK_KEYRING_NAME
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `number` | n/a | yes |
| bucket\_class | The storage class for the bucket being provisioned. | `string` | `"STANDARD"` | no |
| bucket\_force\_destroy | When deleting a bucket, this boolean option will delete all contained objects. If you try to delete a bucket that contains objects, Terraform will fail that run. | `bool` | `false` | no |
| bucket\_lifecycle\_rules | List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches\_storage\_class should be a comma delimited string. | <pre>set(object({<br>    action    = any<br>    condition = any<br>  }))</pre> | <pre>[<br>  {<br>    "action": {<br>      "type": "Delete"<br>    },<br>    "condition": {<br>      "age": 30,<br>      "matches_storage_class": [<br>        "STANDARD"<br>      ],<br>      "with_state": "ANY"<br>    }<br>  }<br>]</pre> | no |
| bucket\_name | The name of for the bucket being provisioned. | `string` | n/a | yes |
| cmek\_keyring\_name | The Keyring name for the KMS Customer Managed Encryption Keys being provisioned. | `string` | n/a | yes |
| data\_governance\_project\_id | The ID of the project in which the data governance resources will be created. | `string` | n/a | yes |
| data\_ingestion\_project\_id | The ID of the project in which the data ingestion resources will be created | `string` | n/a | yes |
| datalake\_project\_id | The ID of the project in which the Bigquery will be created. | `string` | n/a | yes |
| dataset\_default\_table\_expiration\_ms | TTL of tables using the dataset in MS. The default value is almost 12 months. | `number` | `31536000000` | no |
| dataset\_description | Dataset description. | `string` | `"Ingest dataset"` | no |
| dataset\_id | Unique ID for the dataset being provisioned. | `string` | n/a | yes |
| dataset\_name | Friendly name for the dataset being provisioned. | `string` | `"Ingest dataset"` | no |
| location | The location for the KMS Customer Managed Encryption Keys, Bucket, and Bigquery dataset. This location can be a multiregion, if it is empty the region value will be used. | `string` | `""` | no |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_additional\_members | The list additional members to be added on perimeter access. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required. | `list(string)` | `[]` | no |
| privileged\_data\_project\_id | Project where the privileged datasets and tables are created. | `string` | n/a | yes |
| region | The region in which the resources will be deployed. | `string` | `"us-central1"` | no |
| subnet\_ip | The CDIR IP range of the subnetwork. | `string` | n/a | yes |
| terraform\_service\_account | The email address of the service account that will run the Terraform code. | `string` | n/a | yes |
| trusted\_locations | This is a list of trusted regions where location-based GCP resources can be created. ie us-locations eu-locations. | `list(string)` | <pre>[<br>  "us-locations",<br>  "eu-locations"<br>]</pre> | no |
| vpc\_name | The name of the network. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cmek\_bigquery\_crypto\_key | The Customer Managed Crypto Key for the BigQuery service. |
| cmek\_ingestion\_crypto\_key | The Customer Managed Crypto Key for the Ingestion crypto boundary. |
| cmek\_keyring\_full\_name | The Keyring full name for the KMS Customer Managed Encryption Keys. |
| cmek\_keyring\_name | The Keyring name for the KMS Customer Managed Encryption Keys. |
| data\_governance\_access\_level\_name | Access context manager access level name. |
| data\_governance\_service\_perimeter\_name | Access context manager service perimeter name. |
| data\_ingest\_bigquery\_dataset | The bigquery dataset created for data ingest pipeline. |
| data\_ingest\_bucket\_names | The name list of the buckets created for data ingest pipeline. |
| data\_ingest\_topic\_name | The topic created for data ingest pipeline. |
| data\_ingestion\_access\_level\_name | Access context manager access level name. |
| data\_ingestion\_service\_perimeter\_name | Access context manager service perimeter name. |
| dataflow\_controller\_service\_account\_email | The Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account. |
| network\_name | The name of the VPC being created. |
| network\_self\_link | The URI of the VPC being created. |
| privileged\_access\_level\_name | Access context manager access level name. |
| privileged\_service\_perimeter\_name | Access context manager service perimeter name. |
| pubsub\_writer\_service\_account\_email | The PubSub writer service account email. Should be used to write data to the PubSub topics the ingestion pipeline reads from. |
| storage\_writer\_service\_account\_email | The Storage writer service account email. Should be used to write data to the buckets the ingestion pipeline reads from. |
| subnets\_ips | The IPs and CIDRs of the subnets being created. |
| subnets\_names | The names of the subnets being created. |
| subnets\_regions | The region where the subnets will be created. |
| subnets\_self\_links | The self-links of subnets being created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

Install the following dependencies:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.67.0

### Service Account

To provision the resources of this module, create a service account
with the following roles:

- Storage Admin: `roles/storage.admin`

You can use the [Project Factory module][project-factory-module] and the
[IAM module][iam-module] in combination to provision a
service account with the necessary roles applied.

### APIs

Create a project with the following APIs enabled mto host the
resources of this module:

- Google Cloud Storage JSON API: `storage-api.googleapis.com`

You can use he [Project Factory module][project-factory-module] to
provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

---
This is not an officially supported Google product
