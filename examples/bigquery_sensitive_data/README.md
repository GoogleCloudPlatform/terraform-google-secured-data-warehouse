# bigquery_sensitive_data Submodule Example

This example illustrates how to use the `bigquery_sensitive_data` submodule.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dataset\_id | The dataset ID to deploy to data warehouse. | `string` | `"dtwh_dataset"` | yes |
| location | Default region to create resources where applicable. | `string` | `"us-east1"` | yes |
| project\_id | The project where the dataset and table are created. | `string` | n/a | yes |
| table\_id | The table ID to deploy to data warehouse. | `string` | `"sample_data"` | yes |
| taxonomy\_name | The taxonomy display name. | `string` | `"secure_taxonomy_bq"` | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dataset\_id | The dataset ID to deploy to data warehouse. |
| location | The region for storing your BigQuery data when you create a dataset. |
| project\_id | The project where the service accounts are created and the Google Cloud APIs are enabled. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
