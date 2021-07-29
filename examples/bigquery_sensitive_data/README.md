# bigquery_sensitive_data Submodule Example

This example illustrates how to use the `bigquery_sensitive_data` submodule.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bigquery\_project\_id | Project where the dataset and table are created. | `string` | n/a | yes |
| taxonomy\_project\_id | Project where the taxonomy is created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bigquery\_project\_id | Project where bigquery and table were created. |
| emails\_list | The service account email addresses by name. |
| member\_policy\_name\_confidential | SA member for Person Name policy tag confidential. |
| member\_policy\_name\_private | SA member for Person Name policy tag private. |
| member\_policy\_ssn\_confidential | SA member for Social Security Number policy tag confidential. |
| person\_name\_policy\_tag | Content for Policy Tag ID in medium policy. |
| social\_security\_number\_policy\_tag | Content for Policy Tag ID in high policy. |
| taxonomy\_name | The taxonomy display name. |
| taxonomy\_project\_id | Project where taxonomy was created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
