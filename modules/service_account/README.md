# Service account module
This module creates the service account requried for data ingestion.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_id | The ID of the service account to be created. | `string` | n/a | yes |
| display\_name | The display name of the service account to be created. | `string` | n/a | yes |
| org\_id | GCP Organization ID. | `string` | `""` | no |
| organization\_roles | The roles to be granted to the service account in the organization. | `list(string)` | `[]` | no |
| project\_id | The ID of the project in which the service account will be created. | `string` | n/a | yes |
| project\_roles | The roles to be granted to the service account in the project. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| email | The service account email. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
