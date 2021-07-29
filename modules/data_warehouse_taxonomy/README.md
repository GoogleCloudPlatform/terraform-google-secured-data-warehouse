# Secured BigQuery

This module creates:

- A taxonomy and two policy tags that are split into two layers: confidential and private.
- A BigQuery dataset.
- A BigQuery table where policy tags will be applied.
- Two service accounts that are bound to the policy tags.

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
| bigquery\_project\_id | Project where the dataset and table are created. | `string` | n/a | yes |
| dataset\_id | The dataset ID to deploy to data warehouse. | `string` | n/a | yes |
| dataset\_labels | Key value pairs in a map for dataset labels. | `map(string)` | `{}` | no |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `null` | no |
| location | Default region to create resources where applicable. | `string` | n/a | yes |
| project\_roles | Common roles to apply to all service accounts in the project. | `list(string)` | `[]` | no |
| table\_id | The table ID to deploy to data warehouse. | `string` | n/a | yes |
| taxonomy\_name | The taxonomy display name. | `string` | n/a | yes |
| taxonomy\_project\_id | Project where the taxonomy is going to be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| emails\_list | The service account email addresses by name. |
| high\_policy\_taxonomy\_id | Content for Policy Tag ID in high policy. |
| medium\_policy\_taxonomy\_id | Content for Policy Tag ID in medium policy. |
| member\_policy\_name\_confidential | SA member for Person Name policy tag. |
| member\_policy\_name\_private | SA member for Person Name policy tag. |
| member\_policy\_ssn\_confidential | SA member for Social Security Number policy tag. |
| taxonomy\_name | The taxonomy display name. |

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
