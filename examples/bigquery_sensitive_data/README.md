# bigquery_sensitive_data Submodule Example

This example illustrates how to use the `bigquery_sensitive_data` submodule.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | Project where the dataset and table are created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| emails | The service account email addresses by name. |
| member\_policy\_name\_confidential | SA member for Person Name policy tag confidential. |
| member\_policy\_name\_private | SA member for Person Name policy tag private. |
| member\_policy\_ssn\_confidential | SA member for Social Security Number policy tag confidential. |
| person\_name\_policy\_tag | Content for Policy Tag ID in medium policy. |
| project\_id | Project where service accounts and core APIs will be enabled. |
| social\_security\_number\_policy\_tag | Content for Policy Tag ID in high policy. |
| taxonomy\_name | The taxonomy display name. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
