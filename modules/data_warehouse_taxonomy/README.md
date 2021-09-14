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
| cmek\_keyring\_name | The Keyring name for the KMS Customer Managed Encryption Keys. | `string` | n/a | yes |
| cmek\_location | The location for the KMS Customer Managed Encryption Keys. | `string` | n/a | yes |
| confidential\_access\_members | List of members in the standard GCP form: user:{email}, serviceAccount:{email}, group:{email} who will have access to confidential information in BigQuery. | `list(string)` | `[]` | no |
| dataset\_default\_table\_expiration\_ms | TTL of tables using the dataset in MS. The default value is 30 days. | `number` | `2592000000` | no |
| dataset\_id | The dataset ID to deploy to data warehouse. | `string` | n/a | yes |
| dataset\_labels | Key value pairs in a map for dataset labels. | `map(string)` | `{}` | no |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| key\_rotation\_period\_seconds | Rotation period for keys. The default value is 30 days. | `string` | `"2592000s"` | no |
| location | Default region to create resources where applicable. | `string` | n/a | yes |
| non\_sensitive\_project\_id | Project with the de-identified dataset and table. | `string` | n/a | yes |
| private\_access\_members | List of members in the standard GCP form: user:{email}, serviceAccount:{email}, group:{email} who will have access to private information in BigQuery. | `list(string)` | `[]` | no |
| privileged\_data\_project\_id | Project where the privileged datasets and tables are created. | `string` | n/a | yes |
| project\_roles | Common roles to apply to all service accounts in the project. | `list(string)` | `[]` | no |
| table\_id | The table ID to deploy to data warehouse. | `string` | n/a | yes |
| taxonomy\_name | The taxonomy display name. | `string` | n/a | yes |
| taxonomy\_project\_id | Project where the taxonomy is going to be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cmek\_bigquery\_crypto\_key | The Customer Managed Crypto Key for the BigQuery service. |
| cmek\_keyring\_full\_name | The Keyring full name for the KMS Customer Managed Encryption Keys. |
| cmek\_keyring\_name | The Keyring name for the KMS Customer Managed Encryption Keys. |
| cmek\_reidentification\_crypto\_key | The Customer Managed Crypto Key for the reidentification crypto boundary. |
| dataflow\_controller\_service\_account\_email | The Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account. |
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
