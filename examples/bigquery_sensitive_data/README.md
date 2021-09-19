# bigquery_sensitive_data Submodule Example

This example illustrates how to use the `bigquery_sensitive_data` submodule.

## Requirements

You need to create network and subnetwork in the privileged project.

### Firewall rules

- All the egress should be denied
- Allow only Restricted API Egress by TPC at 443 port
- Allow only Private API Egress by TPC at 443 port
- Allow ingress Dataflow workers by TPC at ports 12345 and 12346
- Allow egress Dataflow workers     by TPC at ports 12345 and 12346
### DNS configuration

- Restricted Google APIs
- Private Google APIs
- Restricted gcr.io
- Restricted Artifact Registry


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `number` | n/a | yes |
| crypto\_key | The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP. | `string` | n/a | yes |
| data\_governance\_project\_id | The ID of the project in which the data governance resources will be created. | `string` | n/a | yes |
| data\_ingestion\_project\_id | The ID of the project in which the data ingestion resources will be created. | `string` | n/a | yes |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| flex\_template\_gs\_path | The Google Cloud Storage gs path to the JSON file built flex template that supports DLP re-identification. | `string` | `""` | no |
| network\_self\_link | The URI of the network where Dataflow is going to be deployed. | `string` | n/a | yes |
| non\_sensitive\_project\_id | Project with the de-identified dataset and table. | `string` | n/a | yes |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_members | The list of all members to be added on perimeter access. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required. | `list(string)` | `[]` | no |
| privileged\_data\_project\_id | Project where the privileged datasets and tables are created. | `string` | n/a | yes |
| sdx\_project\_number | The Project Number to configure Secure data exchange with egress rule for the dataflow templates. | `string` | n/a | yes |
| subnetwork\_self\_link | The URI of the subnetwork where Dataflow is going to be deployed. | `string` | n/a | yes |
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
