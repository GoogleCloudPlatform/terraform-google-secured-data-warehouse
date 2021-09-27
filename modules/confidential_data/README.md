# Secured BigQuery

This module creates:

- A BigQuery dataset.
- A Bucket to be used as temporary and staging location for Dataflow jobs.
- A Service account to be used as the dataflow controller service account.

## Usage

Basic usage of this module is as follows:

```hcl
module "bigquery_sensitive_data" {
  source  = "github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse//modules/bigquery_sensitive_data"

  dataset_id                  = var.dataset_id
  description                 = "Dataset for BigQuery Sensitive Data"
  project_id                  = var.project_id
  location                    = var.location
}
```
Functional examples are included in the [examples](./examples/bigquery_sensitive_data) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cmek\_confidential\_bigquery\_crypto\_key | The Customer Managed Crypto Key for the confidential BigQuery service. | `string` | n/a | yes |
| cmek\_reidentification\_crypto\_key | The Customer Managed Crypto Key for the reidentification crypto boundary. | `string` | n/a | yes |
| data\_governance\_project\_id | The ID of the project in which the KMS, Datacatalog, and DLP resources are created. | `string` | n/a | yes |
| dataset\_default\_table\_expiration\_ms | TTL of tables using the dataset in MS. The default value is null. | `number` | `null` | no |
| dataset\_id | The dataset ID to deploy to data warehouse. | `string` | n/a | yes |
| dataset\_labels | Key value pairs in a map for dataset labels. | `map(string)` | `{}` | no |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| key\_rotation\_period\_seconds | Rotation period for keys. The default value is 30 days. | `string` | `"2592000s"` | no |
| location | Default region to create resources where applicable. | `string` | n/a | yes |
| non\_sensitive\_project\_id | Project with the de-identified dataset and table. | `string` | n/a | yes |
| privileged\_data\_project\_id | Project where the privileged datasets and tables are created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| confidential\_data\_dataflow\_bucket\_name | The name of the bucket created for dataflow in the confidential data pipeline. |
| confidential\_dataflow\_controller\_service\_account\_email | The confidential Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe the requirements for using this module.

### Software

Install the following dependencies:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.63

### Service Account

Create a service account with the following roles to provision the resources for this module:

- BigQuery Data Owner: `roles/bigquery.dataOwner`,
- Data Catalog Viewer: `roles/datacatalog.viewer`,
- Project IAM Admin: `roles/resourcemanager.projectIamAdmin`,
- Create Service Accounts: `roles/iam.serviceAccountCreator`

### APIs

Create a project with the following APIs enabled to host the resources for this module:

- BigQuery API: `bigquery.googleapis.com`,
- Cloud Resource Manager API: `cloudresourcemanager.googleapis.com`,
- Identity and Access Management: `iam.googleapis.com`
- Cloud Data Catalog API: `datacatalog.googleapis.com`

You can use the [Project Factory module](https://github.com/terraform-google-modules/terraform-google-project-factory) to provision a project with the necessary APIs enabled. To provision the service account, you can use the[IAM module](https://github.com/terraform-google-modules/terraform-google-iam) in combination with the Project Factory module.

### Note:

`google_data_catalog_taxonomy` resource is in beta, and should be used with the terraform-provider-google-beta provider. See
[Provider Versions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_versions) for more details on beta resources.
