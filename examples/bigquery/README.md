# BigQuery Submodule Example

This example illustrates how to use the `bigquery secured-data-warehouse` submodule.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dataset\_id | The dataset ID to deploy to data-warehouse | `string` | `"dtwh_dataset"` | no |
| location | Default region to create resources where applicable. | `string` | `"us-east1"` | no |
| project\_id | Project where the dataset and table are created | `string` | n/a | yes |
| table\_id | The table ID to deploy to datawarehouse. | `string` | `"sample_data"` | no |
| taxonomy\_name | The taxonomy display name. | `string` | `"secure_taxonomy_bq"` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dataset\_id | The dataset ID to deploy to data-warehouse |
| location | Location for storing your BigQuery data when you create a dataset. |
| project\_id | Project where service accounts and core APIs will be enabled. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Setup
Create the `terraform.tfvars` file and add the values from your test environment.

## Run example
1. Run `terraform init`.
1. Run `terraform plan`.
1. Run `terraform apply`.
1. Populate your dataset with sample data:
   ```
   export DATASET_ID=<your-dataset-id>
   bq load $DATASET_ID.sample_data \
   sample_data.txt name:string,gender:string,social_security_number:integer
   ```
**Note:**
You can use the command below to list your dataset_id.
```
bq ls --project_id <my-project-id>
```
