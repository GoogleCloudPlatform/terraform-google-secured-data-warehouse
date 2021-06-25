# Secured Data Warehouse Blueprint

This repository contains Terraform configuration modules that allow Google Cloud customers to
quickly deploy a secured [BigQuery](https://cloud.google.com/bigquery) data warehouse. The blueprint allows customers
to use Google Cloud's core strengths in data analytics, and to overcome typical
challenges that include:

- Limited knowledge/experience with best practices for creating, deploying, and operating in Google
Cloud.
- Security/risk concerns and restrictions from their internal security, risk, and compliance teams.
- Regulatory and compliance approval from external auditors.

The Terraform configurations in this repository provide customers with an opinionated architecture
that incorporates and documents best practices for a performant and scalable design, combined with
security by default for control, logging and evidence generation. It can be  simply deployed by
customers through a Terraform workflow.

## Usage

Basic usage of this module is as follows:

```hcl
module "secured_data_warehouse" {
  source  = "terraform-google-modules/secured-data-warehouse/google"
  version = "~> 0.1"

  project_id  = "<PROJECT ID>"
  bucket_name = "gcs-test-bucket"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_name | The name of the bucket to create. | `any` | n/a | yes |
| project\_id | The project ID to deploy to. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_name | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

Install the following dependencies:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.67.0

### Service Account

To provision the resources of this module, create a service account 
with the following roles:

- Storage Admin: `roles/storage.admin`

You can use the [Project Factory module][project-factory-module] and the
[IAM module][iam-module] in combination to provision a
service account with the necessary roles applied.

### APIs

Create a project with the following APIs enabled mto host the
resources of this module:

- Google Cloud Storage JSON API: `storage-api.googleapis.com`

You can use he [Project Factory module][project-factory-module] to
provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

---
This is not an officially supported Google product
