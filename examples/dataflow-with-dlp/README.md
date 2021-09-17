# Dataflow with DLP de-identification

This example illustrates how to run a Dataflow job that uses the `de_identification_template` submodule with the `base-data-ingestion` submodule.

## Prerequisites

1. base-data-ingestion executed successfully.
2. A `crypto_key` and `wrapped_key` pair.  Contact your Security Team to obtain the pair. The `crypto_key` location must be the same location where DLP, Storage and BigQuery are going to be created (`local.region`).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `number` | n/a | yes |
| crypto\_key | The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP. | `string` | n/a | yes |
| data\_governance\_project\_id | The ID of the project in which the data governance resources will be created. | `string` | n/a | yes |
| data\_ingestion\_project\_id | The ID of the project in which the data ingestion resources will be created. | `string` | n/a | yes |
| datalake\_project\_id | The ID of the project in which the Bigquery will be created. | `string` | n/a | yes |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| network\_self\_link | The URI of the network where Dataflow is going to be deployed. | `string` | n/a | yes |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| privileged\_data\_project\_id | Project where the privileged datasets and tables are created. | `string` | n/a | yes |
| subnetwork\_self\_link | The URI of the subnetwork where Dataflow is going to be deployed. | `string` | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |
| wrapped\_key | The base64 encoded data crypto key wrapped by KMS. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_ingestion\_name | The name of the bucket. |
| bucket\_tmp\_name | The name of the bucket. |
| controller\_service\_account | The Service Account email that will be used to identify the VMs in which the jobs are running. |
| df\_job\_id | The unique Id of the newly created Dataflow job. |
| df\_job\_name | The name of the newly created Dataflow job. |
| df\_job\_network | The URI of the VPC being created. |
| df\_job\_region | The region of the newly created Dataflow job. |
| df\_job\_state | The state of the newly created Dataflow job. |
| df\_job\_subnetwork | The name of the subnetwork used for create Dataflow job. |
| dlp\_location | The location of the DLP resources. |
| project\_id | The project's ID. |
| template\_id | The ID of the Cloud DLP de-identification template that is created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
