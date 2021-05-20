# Service account module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| organization\_roles | The roles to be granted to the service account in the organization. | `list(string)` | `[]` | no |
| project\_id | The ID of the project in which the service account will be created. | `string` | n/a | yes |
| project\_roles | The roles to be granted to the service account in the project. | `list(string)` | `[]` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dataflow\_controller\_service\_account\_email | The service account email. |
| pubsub\_writer\_service\_account\_email | The service account email. |
| storage\_writer\_service\_account\_email | The service account email. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
