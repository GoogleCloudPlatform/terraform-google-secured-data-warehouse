# Dataflow with DLP de-identification

This example illustrates how to run a Dataflow job that uses the `de_identification_template` submodule with the `1-data-ingestion` step.

## Prerequisites

1. 1-data-ingestion executed successfully.
2. A `crypto_key` and `wrapped_key` pair.  Contact your Security Team to obtain the pair. The `crypto_key` location must be the same location used for the `dlp_location`.

## Usage

To provision this example, complete these tasks from within this directory:

1. Initialize the directory:
   ```
   terraform init
   ```
1. Review the infrastructure plan. When prompted, enter the `project_id`, `terraform_service_account`, `network_self_link`, `subnetwork_self_link`, `dataset_id`, `dlp_location`, `crypto_key` and `wrapped_key`
   ```
   terraform plan
   ```
1. After reviewing the plan, apply it:
   ```
   terraform apply
   ```
1. After you are done with the example, destroy the built infrastructure:
   ```
   terraform destroy
   ```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| crypto\_key | The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP. | `string` | n/a | yes |
| dataflow\_service\_account | The Service Account email that will be used to identify the VMs in which the jobs are running | `string` | n/a | yes |
| dataset\_id | Unique ID for the dataset being provisioned. | `string` | `"dts_test_int"` | no |
| network\_self\_link | The network self link to which VMs will be assigned. | `string` | n/a | yes |
| project\_id | The ID of the project in which the service account will be created. | `string` | n/a | yes |
| subnetwork\_self\_link | The subnetwork self link to which VMs will be assigned. | `string` | n/a | yes |
| table\_name | Unique ID for the table in dataset being provisioned. | `string` | `"table_test_int"` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |
| wrapped\_key | The base64 encoded data crypto key wrapped by KMS. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_name | The name of the bucket |
| controller\_service\_account | The Service Account email that will be used to identify the VMs in which the jobs are running |
| dlp\_location | The location of the DLP resources. |
| project\_id | The project's ID |
| scheduler\_id | Cloud Scheduler Job id created |
| template\_id | The ID of the Cloud DLP de-identification template that is created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
