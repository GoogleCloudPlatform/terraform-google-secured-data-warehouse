# Service account module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_location | Bucket location. | `string` | `"EU"` | no |
| bucket\_name | The main part of the name of the bucket to be created. | `string` | n/a | yes |
| dataset\_default\_table\_expiration\_ms | TTL of tables using the dataset in MS | `number` | `31536000000` | no |
| dataset\_description | Dataset description. | `string` | `"Ingest dataset"` | no |
| dataset\_id | Unique ID for the dataset being provisioned. | `string` | n/a | yes |
| dataset\_location | The regional location for the dataset only US and EU are allowed in module | `string` | `"US"` | no |
| dataset\_name | Friendly name for the dataset being provisioned. | `string` | `"Ingest dataset"` | no |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| project\_id | The ID of the project in which the service account will be created. | `string` | n/a | yes |
| region | The region in which the subnetwork will be created. | `string` | n/a | yes |
| subnet\_ip | The CDIR IP range of the subnetwork. | `string` | `"10.0.32.0/21"` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dataflow\_controller\_service\_account\_email | The service account email. |
| pubsub\_writer\_service\_account\_email | The service account email. |
| storage\_writer\_service\_account\_email | The service account email. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
