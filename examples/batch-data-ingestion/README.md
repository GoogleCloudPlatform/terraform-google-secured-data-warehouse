# Batch Dataflow with DLP de-identification

This example illustrates how to run a public Batch Dataflow job, [Cloud Storage Text to BigQuery](https://cloud.google.com/dataflow/docs/guides/templates/provided-batch#gcstexttobigquery)
with Google Cloud Scheduler [job](https://cloud.google.com/scheduler/docs/creating#creating_jobs) in the [Secured data warehouse](../../README.md) infrastructure.

It uses:

- The [Secured data warehouse](../../README.md) module to create the Secured data warehouse infrastructure.
- The public Google provided Dataflow template [Cloud Storage Text to BigQuery](https://cloud.google.com/dataflow/docs/guides/templates/provided-batch#cloud-storage-text-to-bigquery).
- A Google Cloud Scheduler [job](https://cloud.google.com/scheduler/docs/creating#creating_jobs).

## Requirements

1. The [Secured data warehouse](../../README.md#requirements) module requirements to create the Secured data warehouse infrastructure.
1. The Data Ingestion project must have [Google App Engine Application app](https://cloud.google.com/scheduler/docs/quickstart#create_a_project_with_an_app_engine_app) created.
1. A network and subnetwork in the data ingestion project [configured for Private Google Access](https://cloud.google.com/vpc/docs/configure-private-google-access)
configure with the firewall rules and DNS configurations described below.

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

- Static routes configured to *private* and *restricted* IPs routes. For more information see [Routing options](https://cloud.google.com/vpc/docs/configure-private-google-access#config-routing) in the documentation.

## Generate sample credit card .csv file

This examples uses a [csv file with sample data](./assets/cc_10000_records.csv) as input for the dataflow job.
You can create new files with different sizes using the [sample-cc-generator](../../helpers/sample-cc-generator/README.md) helper.
This new file must be placed in the [assets folder](./assets)
You need to change value of the local `cc_file_name` in the [main.tf](./main.tf#L23) file to use the new sample file:

```hcl
locals {
  ...
  cc_file_name = "cc_10000_records.csv"
  ...
```

## Scheduler Service Account

This example uses the service account created by [Secured data warehouse](../../README.md#outputs) to run [Cloud Scheduler
job](https://cloud.google.com/scheduler/docs/creating#creating_jobs) to create a
[Dataflow Batch pipeline](https://cloud.google.com/dataflow/docs/guides/templates/provided-batch#cloud-storage-text-to-bigquery).

This service account is needed by Cloud Scheduler to run an HTTP request to create a new Batch Dataflow job in a schedulable way,
since the Batch Dataflow job ends when the pipeline finishes .

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `string` | `""` | no |
| confidential\_data\_project\_id | Project where the confidential datasets and tables are created. | `string` | n/a | yes |
| data\_analyst\_group | Google Cloud IAM group that analyzes the data in the warehouse. | `string` | n/a | yes |
| data\_engineer\_group | Google Cloud IAM group that sets up and maintains the data pipeline and warehouse. | `string` | n/a | yes |
| data\_governance\_project\_id | The ID of the project in which the data governance resources will be created. | `string` | n/a | yes |
| data\_ingestion\_project\_id | The ID of the project in which the data ingestion resources will be created. | `string` | n/a | yes |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| network\_administrator\_group | Google Cloud IAM group that reviews network configuration. Typically, this includes members of the networking team. | `string` | n/a | yes |
| network\_self\_link | The URI of the network where Dataflow is going to be deployed. | `string` | n/a | yes |
| non\_confidential\_data\_project\_id | The ID of the project in which the Bigquery will be created. | `string` | n/a | yes |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_additional\_members | The list of all members to be added on perimeter access, except the service accounts created by this module. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required. | `list(string)` | n/a | yes |
| sdx\_project\_number | The Project Number to configure Secure data exchange with egress rule for the dataflow templates. | `string` | n/a | yes |
| security\_administrator\_group | Google Cloud IAM group that administers security configurations in the organization(org policies, KMS, VPC service perimeter). | `string` | n/a | yes |
| security\_analyst\_group | Google Cloud IAM group that monitors and responds to security incidents. | `string` | n/a | yes |
| subnetwork\_self\_link | The URI of the subnetwork where Dataflow is going to be deployed. | `string` | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| controller\_service\_account | The Service Account email that will be used to identify the VMs in which the jobs are running. |
| dataflow\_temp\_bucket\_name | The name of the dataflow temporary bucket. |
| df\_job\_network | The URI of the VPC being created. |
| df\_job\_region | The region of the newly created Dataflow job. |
| df\_job\_subnetwork | The name of the subnetwork used for create Dataflow job. |
| project\_id | The data ingestion project's ID. |
| scheduler\_id | Cloud Scheduler Job id created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
