# Dataflow with DLP de-identification

This example illustrates how to run a Dataflow job that uses the `de_identification_template` submodule with the `base-data-ingestion` submodule.

## Prerequisites

1. base-data-ingestion executed successfully.
2. A `crypto_key` and `wrapped_key` pair.  Contact your Security Team to obtain the pair. The `crypto_key` location must be the same location used for the `dlp_location`.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_force\_destroy | When deleting a bucket, this boolean option will delete all contained objects. If you try to delete a bucket that contains objects, Terraform will fail that run. | `bool` | `false` | no |
| bucket\_location | Dataflow temporary bucket location. | `string` | `"US"` | no |
| crypto\_key | The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP. | `string` | n/a | yes |
| data\_ingestion\_bucket | The bucket name where the files for ingestion is located. | `string` | n/a | yes |
| dataflow\_service\_account | The Service Account email that will be used to identify the VMs in which the jobs are running | `string` | n/a | yes |
| dataset\_id | Unique ID for the dataset being provisioned. | `string` | `"dts_test_int"` | no |
| network\_self\_link | The network self link to which VMs will be assigned. | `string` | n/a | yes |
| project\_id | The ID of the project in which the service account will be created. | `string` | n/a | yes |
| subnetwork\_self\_link | The subnetwork self link to which VMs will be assigned. | `string` | n/a | yes |
| table\_name | Unique ID for the table in dataset being provisioned. | `string` | `"table_test_int"` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| controller\_service\_account | The Service Account email that will be used to identify the VMs in which the jobs are running |
| dataflow\_bucket\_name | The name of the bucket |
| project\_id | The project's ID |
| scheduler\_id | Cloud Scheduler Job id created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
