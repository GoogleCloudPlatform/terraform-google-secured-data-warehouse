# bigquery_sensitive_data Submodule Example

This example illustrates how to use the `bigquery_sensitive_data` submodule.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| crypto\_key | The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP. | `string` | n/a | yes |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| non\_sensitive\_project\_id | Project with the de-identified dataset and table. | `string` | n/a | yes |
| privileged\_data\_project\_id | Project where the privileged datasets and tables are created. | `string` | n/a | yes |
| subnetwork | The subnetwork used for dataflow. | `string` | n/a | yes |
| taxonomy\_project\_id | Project where the taxonomy is created. | `string` | n/a | yes |
| terraform\_service\_account | The email address of the service account that will run the Terraform config. | `string` | n/a | yes |
| wrapped\_key | The base64 encoded data crypto key wrapped by KMS. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| emails\_list | The service account email addresses by name. |
| member\_policy\_name\_confidential | SA member for Person Name policy tag confidential. |
| member\_policy\_name\_private | SA member for Person Name policy tag private. |
| member\_policy\_ssn\_confidential | SA member for Social Security Number policy tag confidential. |
| person\_name\_policy\_tag | Content for Policy Tag ID in medium policy. |
| social\_security\_number\_policy\_tag | Content for Policy Tag ID in high policy. |
| taxonomy\_name | The taxonomy display name. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
