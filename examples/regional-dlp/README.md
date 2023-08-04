# Regional Structured DLP Python Flex Template

This example illustrates how to run a Flex Python Dataflow job in the Secured data warehouse.

This example will deploy the Secured Data Warehouse module and a Python Dataflow flex template pipeline
that reads from Pub/Sub and writes to BigQuery.

To test the pipeline go to the [topic list page](https://console.cloud.google.com/cloudpubsub/topic/list)
and [publish a message](https://cloud.google.com/pubsub/docs/publisher#console)
with the content of the file [books.json](./files/books.json) in the data ingestion topic.

It uses:

- The [Secured data warehouse](../../README.md) module to create the Secured data warehouse infrastructure,
- The [de-identification template](../../modules/de-identification-template/README.md) submodule to create the regional structured DLP template,
- The [Dataflow Flex Template Job](../../modules/dataflow-flex-job/README.md) submodule to deploy a Dataflow Python flex template de-identification job.

## Prerequisites

1. The [Secured data warehouse](../../README.md#requirements) module requirements to create the Secured data warehouse infrastructure.
1. A `crypto_key` and `wrapped_key` pair.  Contact your Security Team to obtain the pair. The `crypto_key` location must be the same location used for the `location` variable. There is a [Wrapped Key Helper](../../helpers/wrapped-key/README.md) python script which generates a wrapped key.
1. The identity deploying the example must have permission to grant roles "roles/cloudkms.cryptoKeyDecrypter" and "roles/cloudkms.cryptoKeyEncrypter" in the KMS `crypto_key`. It will be granted to the Data ingestion Dataflow worker service account created by the Secured Data Warehouse module.
1. A pre-build Python Regional DLP De-identification flex template. See [Flex templates](../../flex-templates/README.md) on how to create them.
1. The identity deploying the example must have permissions to grant role "roles/artifactregistry.reader" in the docker and python repos of the Flex templates.
1. A network and subnetwork in the Data Ingestion project [configured for Private Google Access](https://cloud.google.com/vpc/docs/configure-private-google-access).

### Firewall rules

- [All the egress should be denied](https://cloud.google.com/vpc-service-controls/docs/set-up-private-connectivity#configure-firewall).
- [Allow only Restricted API Egress by TPC at 443 port](https://cloud.google.com/vpc-service-controls/docs/set-up-private-connectivity#configure-firewall).
- [Allow only Private API Egress by TPC at 443 port](https://cloud.google.com/vpc-service-controls/docs/set-up-private-connectivity#configure-firewall).
- [Allow ingress Dataflow workers by TPC at ports 12345 and 12346](https://cloud.google.com/dataflow/docs/guides/routes-firewall#example_firewall_ingress_rule).
- [Allow egress Dataflow workers by TPC at ports 12345 and 12346](https://cloud.google.com/dataflow/docs/guides/routes-firewall#example_firewall_egress_rule).

### DNS configurations

- [Restricted Google APIs](https://cloud.google.com/vpc-service-controls/docs/set-up-private-connectivity#configure-routes).
- [Private Google APIs](https://cloud.google.com/vpc/docs/configure-private-google-access).
- [Restricted gcr.io](https://cloud.google.com/vpc-service-controls/docs/set-up-gke#configure-dns).
- [Restricted Artifact Registry](https://cloud.google.com/vpc-service-controls/docs/set-up-gke#configure-dns).

### Route configuration

- Static routes configured to *private* and *restricted* IPs. For more information see [Routing options](https://cloud.google.com/vpc/docs/configure-private-google-access#config-routing) in the documentation.

### Troubleshooting

If you encounter problems in the apply execution check the [Troubleshooting Guide](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/blob/main/docs/TROUBLESHOOTING.md).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `string` | `""` | no |
| confidential\_data\_project\_id | Project where the confidential datasets and tables are created. | `string` | n/a | yes |
| crypto\_key | The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP. | `string` | n/a | yes |
| data\_analyst\_group | Google Cloud IAM group that analyzes the data in the warehouse. | `string` | n/a | yes |
| data\_engineer\_group | Google Cloud IAM group that sets up and maintains the data pipeline and warehouse. | `string` | n/a | yes |
| data\_governance\_project\_id | The ID of the project in which the data governance resources will be created. | `string` | n/a | yes |
| data\_ingestion\_project\_id | The ID of the project in which the data ingestion resources will be created. | `string` | n/a | yes |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| external\_flex\_template\_project\_id | Project id of the external project that hosts the flex Dataflow templates. | `string` | n/a | yes |
| flex\_template\_gs\_path | The Google Cloud Storage gs path to the JSON file built flex template that supports DLP de-identification. | `string` | `""` | no |
| network\_administrator\_group | Google Cloud IAM group that reviews network configuration. Typically, this includes members of the networking team. | `string` | n/a | yes |
| non\_confidential\_data\_project\_id | The ID of the project in which the Bigquery will be created. | `string` | n/a | yes |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_additional\_members | The list of all members to be added on perimeter access, except the service accounts created by this module. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required. | `list(string)` | n/a | yes |
| sdx\_project\_number | The Project Number to configure Secure data exchange with egress rule for the dataflow templates. | `string` | n/a | yes |
| security\_administrator\_group | Google Cloud IAM group that administers security configurations in the organization(org policies, KMS, VPC service perimeter). | `string` | n/a | yes |
| security\_analyst\_group | Google Cloud IAM group that monitors and responds to security incidents. | `string` | n/a | yes |
| subnetwork\_self\_link | The URI of the subnetwork where Dataflow is going to be deployed. | `string` | n/a | yes |
| terraform\_service\_account | The email address of the service account that will run the Terraform config. | `string` | n/a | yes |
| wrapped\_key | The base64 encoded data crypto key wrapped by KMS. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| template\_full\_path | The full path of the DLP de-identification template. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
