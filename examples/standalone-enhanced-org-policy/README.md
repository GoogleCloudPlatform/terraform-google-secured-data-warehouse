# Enhanced Org Policies to Standalone Example

This examples deploys the *Secured Data Warehouse* blueprint [module](../../README.md).
Using this example you can choose between using existing projects or
letting the example create the required projects needed to deploy it.

Setting the variable `create_projects` to `true` will make the example create the four projects needed by the *Secured Data Warehouse*:

- Data Governance project.
- Data Ingestion project.
- Non-Confidential Data project.
- Confidential Data project.

### Organization Policies

This example will apply 4 organization policies in the project level:

- [org_domain_restricted_sharing](https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains):
The Resource Manager provides a domain restriction constraint that can be used in organization policies to limit resource sharing based on domain.

- [org_enforce_bucket_level_access](https://cloud.google.com/storage/docs/uniform-bucket-level-access): Allows you to uniformly control access to your Cloud Storage resources. When you enable uniform bucket-level access on a bucket, Access Control Lists (ACLs) are disabled, and only bucket-level Identity and Access Management (IAM) permissions grant access to that bucket and the objects it contains.

- [org_enforce_detailed_audit_logging_mode](https://cloud.google.com/storage/docs/org-policy-constraints): When you apply the detailedAuditLoggingMode constraint, Cloud Audit Logs logs associated with Cloud Storage operations contain detailed request and response information. This constraint is recommended to be used in conjunction with Bucket Lock when seeking various compliances such as SEC Rule 17a-4(f), CFTC Rule 1.31(c)-(d), and FINRA Rule 4511(c).

- [org_enforce_public_access_prevention](https://cloud.google.com/storage/docs/public-access-prevention): Public access prevention protects Cloud Storage buckets and objects from being accidentally exposed to the public.


## Usage

To provision this example, run the following from within this directory:

- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure

### Clean up

- Run `terraform destroy` to clean up your environment.

### Perimeter members list

To be able to see the resources protected by the VPC Service Controls [Perimeters](https://cloud.google.com/vpc-service-controls/docs/service-perimeters) in the Google Cloud Console
you need to add your user in the variable `perimeter_additional_members`.

## Requirements

1. The [Secured data warehouse](../../README.md#requirements) module requirements to create the Secured data warehouse infrastructure.

If the projects are created by the example, instead of the project level roles listed in the main module [README](../../README.md#service_account) you will need the following roles in the folder in which the projects will be created:

- Logging Admin: `roles/logging.admin`
- Project Creator: `roles/resourcemanager.projectCreator`
- Project Deleter: `roles/resourcemanager.projectDeleter`
- Project IAM Admin: `roles/resourcemanager.projectIamAdmin`
- Service Usage Admin: `roles/serviceusage.serviceUsageAdmin`

It will also be necessary to grant the `Billing Account User` role to the [service account](https://cloud.google.com/billing/docs/how-to/billing-access#update-cloud-billing-permissions).

You can run the following `gcloud` command to assign `Billing Account User` role to the service account.

```sh
export SA_EMAIL=<YOUR-SA-EMAIL>
export BILLING_ACCOUNT=<YOUR-BILLING-ACCOUNT>

gcloud beta billing accounts add-iam-policy-binding "${BILLING_ACCOUNT}" \
--member="serviceAccount:${SA_EMAIL}" \
--role="roles/billing.user"
```

The user using this service account must have the necessary roles, `Service Account User` and `Service Account Token Creator`, to [impersonate](https://cloud.google.com/iam/docs/impersonating-service-accounts) the service account.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `string` | `""` | no |
| billing\_account | The billing account id associated with the project, e.g. XXXXXX-YYYYYY-ZZZZZZ. | `string` | n/a | yes |
| confidential\_data\_project\_id | Project where the confidential datasets and tables are created. If the variable create\_projects is set to true then new projects will be created for the data warehouse, if set to false existing projects will be used. | `string` | n/a | yes |
| create\_projects | (Optional) If set to true to create new projects for the data warehouse, if set to false existing projects will be used. | `bool` | `false` | no |
| data\_analyst\_group | Google Cloud IAM group that analyzes the data in the warehouse. | `string` | n/a | yes |
| data\_engineer\_group | Google Cloud IAM group that sets up and maintains the data pipeline and warehouse. | `string` | n/a | yes |
| data\_governance\_project\_id | The ID of the project in which the data governance resources will be created. If the variable create\_projects is set to true then new projects will be created for the data warehouse, if set to false existing projects will be used. | `string` | n/a | yes |
| data\_ingestion\_project\_id | The ID of the project in which the data ingestion resources will be created. If the variable create\_projects is set to true then new projects will be created for the data warehouse, if set to false existing projects will be used. | `string` | n/a | yes |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| domains\_to\_allow | The list of domains to allow users from in IAM. Used by Domain Restricted Sharing Organization Policy. Must include the domain of the organization you are deploying the blueprint. To add other domains you must also grant access to these domains to the terraform service account used in the deploy. | `list(string)` | n/a | yes |
| folder\_id | The folder where the projects will be deployed in case you set the variable create\_projects as true. | `string` | n/a | yes |
| network\_administrator\_group | Google Cloud IAM group that reviews network configuration. Typically, this includes members of the networking team. | `string` | n/a | yes |
| non\_confidential\_data\_project\_id | The ID of the project in which the Bigquery will be created. If the variable create\_projects is set to true then new projects will be created for the data warehouse, if set to false existing projects will be used. | `string` | n/a | yes |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_additional\_members | The list of all members to be added on perimeter access, except the service accounts created by this module. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required. | `list(string)` | n/a | yes |
| sdx\_project\_number | (Optional) The Project Number to configure Secure data exchange with egress rule for the dataflow templates. | `string` | `""` | no |
| security\_administrator\_group | Google Cloud IAM group that administers security configurations in the organization(org policies, KMS, VPC service perimeter). | `string` | n/a | yes |
| security\_analyst\_group | Google Cloud IAM group that monitors and responds to security incidents. | `string` | n/a | yes |
| terraform\_service\_account | The email address of the service account that will run the Terraform code. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| blueprint\_type | Type of blueprint this module represents. |
| cmek\_bigquery\_crypto\_key | The Customer Managed Crypto Key for the BigQuery service. |
| cmek\_confidential\_bigquery\_crypto\_key | The Customer Managed Crypto Key for the confidential BigQuery service. |
| cmek\_data\_ingestion\_crypto\_key | The Customer Managed Crypto Key for the data ingestion crypto boundary. |
| cmek\_reidentification\_crypto\_key | The Customer Managed Crypto Key for the reidentification crypto boundary. |
| confidential\_data\_service\_perimeter\_name | Confidential Data VPC Service Controls service perimeter name |
| data\_governance\_service\_perimeter\_name | Data Governance VPC Service Controls service perimeter name. |
| data\_ingestion\_bigquery\_dataset | The bigquery dataset created for data ingestion pipeline. |
| data\_ingestion\_bucket\_name | The name of the bucket created for the data ingestion pipeline. |
| data\_ingestion\_service\_perimeter\_name | Data Ingestion VPC Service Controls service perimeter name. |
| data\_ingestion\_topic\_name | The topic created for data ingestion pipeline. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
