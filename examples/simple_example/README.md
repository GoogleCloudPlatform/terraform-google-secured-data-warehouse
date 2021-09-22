# Simple Example

This example illustrates how to use the `secured-data-warehouse` module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `number` | n/a | yes |
| data\_governance\_project\_id | The ID of the project in which the data governance resources will be created. | `string` | n/a | yes |
| data\_ingestion\_project\_id | The ID of the project in which the data ingestion resources will be created. | `string` | n/a | yes |
| datalake\_project\_id | The ID of the project in which the Bigquery will be created. | `string` | n/a | yes |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| privileged\_data\_project\_id | Project where the privileged datasets and tables are created. | `string` | n/a | yes |
| sdx\_project\_number | The Project Number to configure Secure data exchange with egress rule for the dataflow templates. | `string` | n/a | yes |
| terraform\_service\_account | The email address of the service account that will run the Terraform code. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cmek\_bigquery\_crypto\_key | The Customer Managed Crypto Key for the BigQuery service. |
| cmek\_bigquery\_crypto\_key\_name | The Customer Managed Crypto Key name for the BigQuery service. |
| cmek\_confidential\_bigquery\_crypto\_key\_name | The Customer Managed Crypto Key name for the confidential BigQuery service. |
| cmek\_ingestion\_crypto\_key | The Customer Managed Crypto Key for the Ingestion crypto boundary. |
| cmek\_ingestion\_crypto\_key\_name | The Customer Managed Crypto Key name for the Ingestion crypto boundary. |
| cmek\_keyring\_full\_name | The Keyring full name for the KMS Customer Managed Encryption Keys. |
| cmek\_keyring\_name | The Keyring name for the KMS Customer Managed Encryption Keys. |
| cmek\_reidentification\_crypto\_key\_name | The Customer Managed Crypto Key name for the reidentification crypto boundary. |
| data\_ingest\_bigquery\_dataset | The bigquery dataset created for data ingest pipeline. |
| data\_ingest\_bucket\_names | The name list of the buckets created for data ingest pipeline. |
| data\_ingest\_topic\_name | The topic created for data ingest pipeline. |
| data\_ingestion\_access\_level\_name | Access context manager access level name. |
| data\_ingestion\_service\_perimeter\_name | Access context manager service perimeter name. |
| dataflow\_controller\_service\_account\_email | The Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account. |
| pubsub\_writer\_service\_account\_email | The PubSub writer service account email. Should be used to write data to the PubSub topics the ingestion pipeline reads from. |
| storage\_writer\_service\_account\_email | The Storage writer service account email. Should be used to write data to the buckets the ingestion pipeline reads from. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
