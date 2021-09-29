# Bigquery Sensitive Data Example

This example illustrates how to run a Flex Java re-identification Dataflow job in the Secured data warehouse and
how to use [Data Catalog policy tags](https://cloud.google.com/bigquery/docs/best-practices-policy-tags) to restrict access to sensitive columns in the re-identified table.

It uses:

- The [Secured data warehouse](../README.md) module to create the Secured data warehouse infrastructure,
- The `de_identification_template` submodule to create the regional structured DLP template,
- A Dataflow flex template to deploy the re-identification job.
- A Dataflow flex template to deploy the de-identification job.

## Requirements

1. A `crypto_key` and `wrapped_key` pair.  Contact your Security Team to obtain the pair. The `crypto_key` location must be the same location used for the `location` variable.
1. Pre-build Java Regional DLP De-identification and Re-identification flex templates. See [Flex templates](../../flex_templates/README.md).
1. The identity deploying the example must have permissions to grant role "roles/artifactregistry.reader" in the docker and python repos of the Flex templates.
1. You need to create network and subnetwork in the privileged project.

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
| data\_ingestion\_subnets\_self\_link | The URI of the subnetwork where Data Ingestion Dataflow is going to be deployed. | `string` | n/a | yes |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| external\_flex\_template\_project\_id | Project id of the external project that host the flex Dataflow templates. | `string` | n/a | yes |
| java\_de\_identify\_template\_gs\_path | The Google Cloud Storage gs path to the JSON file built flex template that supports DLP de-identification. | `string` | `""` | no |
| java\_re\_identify\_template\_gs\_path | The Google Cloud Storage gs path to the JSON file built flex template that supports DLP re-identification. | `string` | `""` | no |
| non\_sensitive\_project\_id | Project with the de-identified dataset and table. | `string` | n/a | yes |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_members | The list of all members to be added on perimeter access. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required. | `list(string)` | `[]` | no |
| privileged\_data\_project\_id | Project where the privileged datasets and tables are created. | `string` | n/a | yes |
| privileged\_subnets\_self\_link | The URI of the subnetwork where Data Ingestion Dataflow is going to be deployed. | `string` | n/a | yes |
| sdx\_project\_number | The Project Number to configure Secure data exchange with egress rule for the flex Dataflow templates. | `string` | n/a | yes |
| taxonomy\_name | The taxonomy display name. | `string` | `"secured_taxonomy"` | no |
| terraform\_service\_account | The email address of the service account that will run the Terraform config. | `string` | n/a | yes |
| wrapped\_key | The base64 encoded data crypto key wrapped by KMS. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| taxonomy\_name | The taxonomy display name. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
