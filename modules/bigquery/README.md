# Secured BigQuery

This module creates:

- A Taxonomy and 2 policy tags splitting in 2 layers: confidential and private mode
- A BigQuery dataset
- A BigQuery table where policy tags will be applied
- Two service accounts binded to policy tags

## Usage

Basic usage of this module is as follows:

```hcl
module "secure_bigquery" {
  source  = "github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse//modules/bigquery"

  dataset_id                  = var.dataset_id
  description                 = "Dataset for Secure BigQuery"
  project_id                  = var.project_id
  location                    = var.location
}
```
Functional examples are included in the [examples](./examples/bigquery) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dataset\_id | The dataset ID to deploy to datawarehouse. | `string` | `""` | no |
| location | Default region to create resources where applicable. | `string` | `""` | no |
| names | Names of the service accounts to create. | `list(string)` | `[]` | no |
| parent\_folder | Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist. | `string` | `""` | no |
| project\_id | Project where the dataset and table are created. | `string` | `""` | no |
| project\_roles | Common roles to apply to all service accounts, project=>role as elements. | `list(string)` | `[]` | no |
| table\_id | The table ID to deploy to datawarehouse. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| dataset\_id | The dataset ID to deploy to data-warehouse. |
| emails | The service account emails. |
| high\_policy\_ssn | Content for Social Security Number policy tag. |
| location | Location for storing your BigQuery data when you create a dataset. |
| medium\_policy\_name | Content for Name policy tag. |
| project\_id | Project where service accounts and core APIs will be enabled. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.63

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- BigQuery Data Owner: `roles/bigquery.dataOwner`,
- Data Catalog Viewer: `roles/datacatalog.viewer`,
- Project IAM Admin: `roles/resourcemanager.projectIamAdmin`,
- Create Service Accounts: `roles/iam.serviceAccountCreator`

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- BigQuery API: `bigquery.googleapis.com`,
- Cloud Resource Manager API: `cloudresourcemanager.googleapis.com`,
- Identity and Access Management: `iam.googleapis.com`

The [Project Factory module](https://github.com/terraform-google-modules/terraform-google-project-factory) can be used to
provision a project with the necessary APIs enabled. The
[IAM module](https://github.com/terraform-google-modules/terraform-google-iam) may be used in combination to provision a
service account with the necessary roles applied.
