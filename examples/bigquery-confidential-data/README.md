# Bigquery Confidential Data Example

This example illustrates how to run a Flex Java re-identification Dataflow job in the Secured data warehouse and
how to use [Data Catalog policy tags](https://cloud.google.com/bigquery/docs/best-practices-policy-tags) to restrict access to confidential columns in the re-identified table.

It uses:

- The [Secured data warehouse](../../README.md) module to create the Secured data warehouse infrastructure,
- The [de-identification template](../../modules/de-identification-template/README.md) submodule to create the regional structured DLP template,
- The [Dataflow Flex Template Job](../../modules/dataflow-flex-job/README.md) submodule to deploy a Dataflow flex template re-identification job.
- The [Dataflow Flex Template Job](../../modules/dataflow-flex-job/README.md) submodule to deploy a Dataflow flex template de-identification job.

## Requirements

1. The [Secured data warehouse](../../README.md#requirements) module requirements to create the Secured data warehouse infrastructure.
1. A `crypto_key` and `wrapped_key` pair. Contact your Security Team to obtain the pair. The `crypto_key` location must be the same location used for the `location` variable. There is a [Wrapped Key Helper](../../helpers/wrapped-key/README.md) python script which generates a wrapped key.
1. The identity deploying the example must have permission to grant roles "roles/cloudkms.cryptoKeyDecrypter" and "roles/cloudkms.cryptoKeyEncrypter" in the KMS `crypto_key`. It will be granted to the Data Ingestion Dataflow worker service account and the Confidential Data Dataflow worker service account created by the Secured Data Warehouse module.
1. Pre-build Java Regional DLP De-identification and Re-identification flex templates. See [Flex templates](../../flex-templates/README.md) on how to create them.
1. The identity deploying the example must have permissions to grant role "roles/artifactregistry.reader" in the docker and python repos of the Flex templates.
1. You need to create network and subnetwork in the data ingestion project [configured for Private Google Access](https://cloud.google.com/vpc/docs/configure-private-google-access).
1. You need to create network and subnetwork in the confidential project [configured for Private Google Access](https://cloud.google.com/vpc/docs/configure-private-google-access).

### Firewall rules

- [All the egress should be denied](https://cloud.google.com/vpc-service-controls/docs/set-up-private-connectivity#configure-firewall).
- [Allow only Restricted API Egress by TPC at 443 port](https://cloud.google.com/vpc-service-controls/docs/set-up-private-connectivity#configure-firewall).
- [Allow only Private API Egress by TPC at 443 port](https://cloud.google.com/vpc-service-controls/docs/set-up-private-connectivity#configure-firewall).
- [Allow ingress Dataflow workers by TPC at ports 12345 and 12346](https://cloud.google.com/dataflow/docs/guides/routes-firewall#example_firewall_ingress_rule).
- [Allow egress Dataflow workers by TPC at ports 12345 and 12346](https://cloud.google.com/dataflow/docs/guides/routes-firewall#example_firewall_egress_rule).

### DNS configuration

- [Restricted Google APIs](https://cloud.google.com/vpc-service-controls/docs/set-up-private-connectivity#configure-routes).
- [Private Google APIs](https://cloud.google.com/vpc/docs/configure-private-google-access).
- [Restricted gcr.io](https://cloud.google.com/vpc-service-controls/docs/set-up-gke#configure-dns).
- [Restricted Artifact Registry](https://cloud.google.com/vpc-service-controls/docs/set-up-gke#configure-dns).

### Route configuration

- Static routes configured to *private* and *restricted* IPs. For more information see [Routing options](https://cloud.google.com/vpc/docs/configure-private-google-access#config-routing) in the documentation.

## Generate sample credit card .csv file

This examples uses a [csv file with sample data](./assets/cc_10000_records.csv) as input for the dataflow job.
You can create new files with different sizes using the [sample-cc-generator](../../helpers/sample-cc-generator/README.md) helper.
This new file must be placed in the [assets folder](./assets)
You need to change value of the local `cc_file_name` in the [main.tf](./main.tf#L27) file to use the new sample file:

```hcl
locals {
  ...
  cc_file_name = "cc_10000_records.csv"
  ...
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `string` | `""` | no |
| confidential\_data\_project\_id | Project where the confidential datasets and tables are created. | `string` | n/a | yes |
| confidential\_subnets\_self\_link | The URI of the subnetwork where Data Ingestion Dataflow is going to be deployed. | `string` | n/a | yes |
| crypto\_key | The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP. | `string` | n/a | yes |
| data\_analyst\_group | Google Cloud IAM group that analyzes the data in the warehouse. | `string` | n/a | yes |
| data\_engineer\_group | Google Cloud IAM group that sets up and maintains the data pipeline and warehouse. | `string` | n/a | yes |
| data\_governance\_project\_id | The ID of the project in which the data governance resources will be created. | `string` | n/a | yes |
| data\_ingestion\_project\_id | The ID of the project in which the data ingestion resources will be created. | `string` | n/a | yes |
| data\_ingestion\_subnets\_self\_link | The URI of the subnetwork where Data Ingestion Dataflow is going to be deployed. | `string` | n/a | yes |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| external\_flex\_template\_project\_id | Project id of the external project that host the flex Dataflow templates. | `string` | n/a | yes |
| java\_de\_identify\_template\_gs\_path | The Google Cloud Storage gs path to the JSON file built flex template that supports DLP de-identification. | `string` | n/a | yes |
| java\_re\_identify\_template\_gs\_path | The Google Cloud Storage gs path to the JSON file built flex template that supports DLP re-identification. | `string` | n/a | yes |
| network\_administrator\_group | Google Cloud IAM group that reviews network configuration. Typically, this includes members of the networking team. | `string` | n/a | yes |
| non\_confidential\_data\_project\_id | Project with the de-identified dataset and table. | `string` | n/a | yes |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_additional\_members | The list of all members to be added on perimeter access, except the service accounts created by this module. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required. | `list(string)` | n/a | yes |
| sdx\_project\_number | The Project Number to configure Secure data exchange with egress rule for the flex Dataflow templates. | `string` | n/a | yes |
| security\_administrator\_group | Google Cloud IAM group that administers security configurations in the organization(org policies, KMS, VPC service perimeter). | `string` | n/a | yes |
| security\_analyst\_group | Google Cloud IAM group that monitors and responds to security incidents. | `string` | n/a | yes |
| terraform\_service\_account | The email address of the service account that will run the Terraform config. | `string` | n/a | yes |
| wrapped\_key | The base64 encoded data crypto key wrapped by KMS. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| taxonomy\_name | The taxonomy display name. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
