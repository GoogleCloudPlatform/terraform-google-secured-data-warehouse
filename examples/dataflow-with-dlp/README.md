# Dataflow with DLP de-identification

This example illustrates how to run a regional Dataflow job that uses the `de-identification template` submodule with The [Secured data warehouse](../../README.md).

It uses:

- The [Secured data warehouse](../../README.md) module to create the Secured data warehouse infrastructure
- The [de-identification template](../../modules/de-identification-template/README.md) submodule to create the regional structured DLP template
- A Dataflow flex template to deploy the de-identification job

## Prerequisites

1. A `crypto_key` and `wrapped_key` pair.  Contact your Security Team to obtain the pair. The `crypto_key` location must be the same location where DLP, Storage and BigQuery are going to be created (`local.region`).
1. The identity deploying the example must have permissions to grant role "roles/artifactregistry.reader" in the docker repo of the Flex templates.
1. A network and subnetwork in the landing zone project [configured for Private Google Access](https://cloud.google.com/vpc/docs/configure-private-google-access).

### Firewall rules

- All the egress should be denied
- Allow only Restricted API Egress by TPC at 443 port
- Allow only Private API Egress by TPC at 443 port
- Allow ingress Dataflow workers by TPC at ports 12345 and 12346
- Allow egress Dataflow workers     by TPC at ports 12345 and 12346

### DNS configurations

- Restricted Google APIs
- Private Google APIs
- Restricted gcr.io
- Restricted Artifact Registry

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `number` | n/a | yes |
| confidential\_data\_project\_id | Project where the confidential datasets and tables are created. | `string` | n/a | yes |
| crypto\_key | The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP. | `string` | n/a | yes |
| data\_governance\_project\_id | The ID of the project in which the data governance resources will be created. | `string` | n/a | yes |
| de\_identify\_template\_gs\_path | The Google Cloud Storage gs path to the JSON file built flex template that supports DLP de-identification. | `string` | `""` | no |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| external\_flex\_template\_project\_id | Project id of the external project that host the flex Dataflow templates. | `string` | n/a | yes |
| landing\_zone\_project\_id | The ID of the project in which the landing zone resources will be created. | `string` | n/a | yes |
| network\_self\_link | The URI of the network where Dataflow is going to be deployed. | `string` | n/a | yes |
| non\_confidential\_data\_project\_id | The ID of the project in which the Bigquery will be created. | `string` | n/a | yes |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_additional\_members | The list of all members to be added on perimeter access, except the service accounts created by this module. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required. | `list(string)` | n/a | yes |
| sdx\_project\_number | The Project Number to configure Secure data exchange with egress rule for the flex Dataflow templates. | `string` | n/a | yes |
| subnetwork\_self\_link | The URI of the subnetwork where Dataflow is going to be deployed. | `string` | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |
| wrapped\_key | The base64 encoded data crypto key wrapped by KMS. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_landing\_zone\_name | The name of the bucket. |
| controller\_service\_account | The Service Account email that will be used to identify the VMs in which the jobs are running. |
| df\_job\_network | The URI of the VPC being created. |
| df\_job\_subnetwork | The name of the subnetwork used for create Dataflow job. |
| dlp\_location | The location of the DLP resources. |
| project\_id | The project's ID. |
| template\_id | The ID of the Cloud DLP de-identification template that is created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
