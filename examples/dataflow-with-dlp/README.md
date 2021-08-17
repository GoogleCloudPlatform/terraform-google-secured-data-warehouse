# Dataflow with DLP de-identification

This example illustrates how to run a Dataflow job that uses the `de_identification_template` submodule with the `base-data-ingestion` submodule.

## Prerequisites

1. base-data-ingestion executed successfully.
2. A `crypto_key` and `wrapped_key` pair.  Contact your Security Team to obtain the pair. The `crypto_key` location must be the same location used for the `dlp_location`.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `number` | n/a | yes |
| bucket\_force\_destroy | When deleting a bucket, this boolean option will delete all contained objects. If you try to delete a bucket that contains objects, Terraform will fail that run. | `bool` | `false` | no |
| bucket\_lifecycle\_rules | List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches\_storage\_class should be a comma delimited string. | <pre>set(object({<br>    action    = map(string)<br>    condition = map(string)<br>  }))</pre> | <pre>[<br>  {<br>    "action": {<br>      "type": "Delete"<br>    },<br>    "condition": {<br>      "age": 30,<br>      "with_state": "ANY"<br>    }<br>  }<br>]</pre> | no |
| bucket\_location | Bucket location. | `string` | `"US"` | no |
| bucket\_name | The main part of the name of the data ingestion bucket to be created. | `string` | `"bkt-data-ingestion"` | no |
| cmek\_keyring\_name | The Keyring name for the KMS Customer Managed Encryption Keys. | `string` | `"cmek_keyring"` | no |
| cmek\_location | The location for the KMS Customer Managed Encryption Keys. | `string` | `"us"` | no |
| dataset\_default\_table\_expiration\_ms | TTL of tables using the dataset in MS. The default value is almost 12 months. | `number` | `31536000000` | no |
| dataset\_description | Dataset description. | `string` | `"Ingest dataset"` | no |
| dataset\_id | Unique ID for the dataset being provisioned. | `string` | `"dts_data_ingestion"` | no |
| dataset\_location | The regional location for the dataset only US and EU are allowed in module | `string` | `"US"` | no |
| dataset\_name | Friendly name for the dataset being provisioned. | `string` | `"Ingest dataset"` | no |
| dlp\_location | The location of DLP resources. See https://cloud.google.com/dlp/docs/locations. The 'global' KMS location is valid. | `string` | `"us"` | no |
| ip\_configuration | The configuration for VM IPs. Options are 'WORKER\_IP\_PUBLIC' or 'WORKER\_IP\_PRIVATE'. | `string` | `"WORKER_IP_PRIVATE"` | no |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_additional\_members | The list additional members to be added on perimeter access. Prefix of group: user: or serviceAccount: is required. | `list(string)` | `[]` | no |
| project\_id | The ID of the project in which the service account will be created. | `string` | n/a | yes |
| subnet\_ip | The CDIR IP range of the subnetwork. | `string` | `"10.0.32.0/21"` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_ingestion\_name | The name of the bucket |
| bucket\_tmp\_name | The name of the bucket |
| controller\_service\_account | The Service Account email that will be used to identify the VMs in which the jobs are running |
| df\_job\_id | The unique Id of the newly created Dataflow job |
| df\_job\_name | The name of the newly created Dataflow job |
| df\_job\_region | The region of the newly created Dataflow job. |
| df\_job\_state | The state of the newly created Dataflow job |
| df\_job\_subnetwork | The name of the subnetwork used for create Dataflow job. |
| dlp\_location | The location of the DLP resources. |
| project\_id | The project's ID |
| template\_id | The ID of the Cloud DLP de-identification template that is created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
