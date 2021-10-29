# Standalone Tutorial

This examples deploy the Secured data warehouse blueprint with "batteries included".

## Usage

- Copy `tfvars` by running `cp terraform.example.tfvars terraform.tfvars` and update `terraform.tfvars` with values from your environment.
- Run `terraform init`
- Run `terraform plan` and review the plan
- Run `terraform apply`

## Requirements

These sections describe requirements for running this example.

### Software

Install the following dependencies:

- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 357.0.0 or later
- [Terraform](https://www.terraform.io/downloads.html) version 0.13.7 or later

### Service Account

To provision the resources of this module, create a service account
with the following IAM roles:

- Organization level
  - Access Context Manager Admin: `roles/accesscontextmanager.policyAdmin`
  - Billing User: `roles/billing.user`
  - Organization Administrator: `roles/resourcemanager.organizationAdmin`
  - Organization Policy Administrator: `roles/orgpolicy.policyAdmin`
  - Organization Shared VPC Admin: `roles/compute.xpnAdmin`
  - VPC Access Admin: `roles/vpcaccess.admin`
- Folder Level
  - Project Creator: `roles/resourcemanager.projectCreator`

The service account must have `Billing User role` in the billing account.

You can use the [Project Factory module](https://github.com/terraform-google-modules/terraform-google-project-factory) and the
[IAM module](https://github.com/terraform-google-modules/terraform-google-iam) in combination to provision a
service account with the necessary roles applied.

The user using this service account must have the necessary roles to [impersonate](https://cloud.google.com/iam/docs/impersonating-service-accounts) the service account.

### APIs

The following APIs must be enabled in the project where the service account was created:

- Access Context Manager API: `accesscontextmanager.googleapis.com`
- App Engine Admin API: `appengine.googleapis.com`
- Cloud Billing API:`cloudbilling.googleapis.com`
- Cloud Key Management Service (KMS) API:`cloudkms.googleapis.com`
- Cloud Pub/Sub API: `pubsub.googleapis.com`
- Cloud Resource Manager API:`cloudresourcemanager.googleapis.com`
- Compute Engine API:`compute.googleapis.com`
- Dataflow API:`dataflow.googleapis.com`
- Identity and Access Management (IAM) API:`iam.googleapis.com`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `number` | n/a | yes |
| billing\_account | The billing account id associated with the projects, e.g. XXXXXX-YYYYYY-ZZZZZZ. | `any` | n/a | yes |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| folder\_id | The folder to deploy in. | `any` | n/a | yes |
| kms\_key\_protection\_level | The protection level to use when creating a version based on this template. Default value: "HSM" Possible values: ["SOFTWARE", "HSM"] | `string` | `"HSM"` | no |
| org\_id | The numeric organization id. | `any` | n/a | yes |
| perimeter\_additional\_members | The list of all members to be added on perimeter access, except the service accounts created by this module. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required. | `list(string)` | n/a | yes |
| taxonomy\_name | The taxonomy display name. | `string` | `"secured_taxonomy"` | no |
| terraform\_service\_account | The email address of the service account that will run the Terraform code. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| confidential\_dataflow\_controller\_service\_account\_email | The confidential project Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account. |
| dataflow\_controller\_service\_account\_email | The landing zone project Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account. |
| landing\_zone\_bucket\_name | The name of the bucket created for landing zone pipeline. |
| landing\_zone\_topic\_name | The topic created for landing zone pipeline. |
| pubsub\_writer\_service\_account\_email | The PubSub writer service account email. Should be used to write data to the PubSub topics the landing zone pipeline reads from. |
| storage\_writer\_service\_account\_email | The Storage writer service account email. Should be used to write data to the buckets the landing zone pipeline reads from. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
