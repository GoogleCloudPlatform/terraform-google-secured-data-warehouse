# BigQuery Submodule Example

This example illustrates how to use the `bigquery secured-data-warehouse` submodule.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dataset\_id | The dataset ID to deploy to data-warehouse | `string` | `""` | no |
| location | Default region to create resources where applicable. | `string` | `""` | no |
| project\_id | Project where the dataset and table are created | `string` | `""` | no |
| table\_id | The table ID to deploy to datawarehouse. | `string` | `"sample_data"` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dataset\_id | The dataset ID to deploy to data-warehouse |
| location | Location for storing your BigQuery data when you create a dataset. |
| project\_id | Project where service accounts and core APIs will be enabled. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Setup
Update the contents of `terraform.tfvars` to match your test environment.

## Run example
1. Create file `terraform.tfvars` and add the values from your environment.
1. `terraform init`
1. `terraform plan`
1. `terraform apply`
1. Run the following command to populate your dataset with sample data:
   ```
   export DATASET_ID=<your-dataset-id>
   bq load $DATASET_ID.sample_data \
   sample_data.txt name:string,gender:string,social_security_number:integer
   ```
