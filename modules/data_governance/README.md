# Data Governance submodule

This submodule allows you to create:

- A Cloud [Data Loss Prevention](https://cloud.google.com/dlp/docs) (DLP) [de-identification template](https://cloud.google.com/dlp/docs/deidentify-sensitive-data) from a json template file provided by the user.
- A Cloud [Key Management Service](https://cloud.google.com/kms/docs) (KMS) keyring and key.
- A [KMS wrapped crypto key](https://cloud.google.com/dlp/docs/transformations-reference#crypto) created from a secret provided by the user that can be used by the DLP template.

## Compatibility

This module is meant for use with Terraform 0.13.

## Usage

Basic usage of this module is as follows:

```hcl
module "data_governance" {
  source = "github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse//modules/data_governance"

  project_id                = "PROJECT_ID"
  terraform_service_account = "SERVICE_ACCOUNT_EMAIL"
  crypto_key                = "CRYPTO_KEY"
  wrapped_key               = "WRAPPED_KEY"
  dlp_location              = "DLP_LOCATION"
  template_file             = "PATH_TO_TEMPLATE_FILE"
}
```

### DLP de-identification key

It is necessary to provide a de-identification key that will be encrypted by KMS
and will be used by the de-identification template.


### Template file

The template file must be a json representation of a `deidentifyTemplates` call [request body](https://cloud.google.com/dlp/docs/reference/rest/v2/projects.deidentifyTemplates/create#request-body).

Available substitutions to be used in the template file:

- `display_name`: The display name of the DLP template.
- `description`: The description of the DLP template.
- `wrapped_key`: A user provided encryption key provided by the user encrypted with the `crypto_key`.
- `crypto_key`: The KMS key used to encrypt the `wrapped kwy`.
- `template_id`: The template ID, composed by the variable `template_id_prefix` and a random suffix.

See the terraform [templatefile](https://www.terraform.io/docs/language/functions/templatefile.html) function documentation and
the [sample template file](../../examples/data_governance/deidentification.tmpl) in the examples folder for details on how substitutions are handled.

Since the actual de-identification template is provided by the user,
it can be an [Info Type Transformation](https://cloud.google.com/dlp/docs/reference/rest/v2/projects.deidentifyTemplates#DeidentifyTemplate.InfoTypeTransformations) for unstructured text
or a [Record Transformation](https://cloud.google.com/dlp/docs/reference/rest/v2/projects.deidentifyTemplates#DeidentifyTemplate.RecordTransformations) for structured data.

A functional example for a Record Transformation is included under the
[examples/data_governance](./examples/data_governance/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| crypto\_key | Crypto key used to wrap the wrapped key. | `string` | n/a | yes |
| dlp\_location | The location of DLP resources. See https://cloud.google.com/dlp/docs/locations. The 'global' KMS location is valid. | `string` | n/a | yes |
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |
| template\_description | Description of the DLP de-identification template. | `string` | `"De-identifies sensitive content defined in the template with a KMS Wrapped crypto Key."` | no |
| template\_display\_name | Display name of the DLP de-identification template. | `string` | `"KMS Wrapped crypto Key de-identification"` | no |
| template\_file | Path to the DLP de-identification template file. | `string` | n/a | yes |
| template\_id\_prefix | Prefix of the ID of the DLP de-identification template to be created. | `string` | `""` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |
| wrapped\_key | The Wrapped key. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| crypto\_key | Crypto key used to wrap the wrapped key. |
| dlp\_location | The location of the DLP resources. |
| template\_description | Description of the DLP de-identification template. |
| template\_display\_name | Display name of the DLP de-identification template. |
| template\_id | ID of the DLP de-identification template created. |
| wrapped\_key | The Wrapped key. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform](https://www.terraform.io/downloads.html) >= 0.13.0
- [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) plugin v3.0
- [curl](https://curl.haxx.se/)

### User provided DLP de-identification key

The user must create a Google Cloud Secret Manager secret to hold the DLP de-identification key
**before** executing this module as detailed in the [DLP de-identification key](#dlp-de-identification-key) section.

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Cloud KMS Admin: `roles/cloudkms.admin`
- Cloud KMS CryptoKey Encrypter: `roles/cloudkms.cryptoKeyEncrypter`
- DLP De-identify Templates Editor: `roles/dlp.deidentifyTemplatesEditor`
- DLP Inspect Templates Editor: `roles/dlp.inspectTemplatesEditor`
- DLP User: `roles/dlp.user`
- Service Account Token Creator: `roles/iam.serviceAccountTokenCreator`
- Secret Manager Viewer: `roles/secretmanager.viewer`

The [Project Factory module](https://github.com/terraform-google-modules/terraform-google-project-factory) and the
[IAM module](https://github.com/terraform-google-modules/terraform-google-iam) may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Cloud Key Management Service API: `cloudkms.googleapis.com`
- Cloud Data Loss Prevention API: `dlp.googleapis.com`
- Cloud Identity and Access Management API: `iam.googleapis.com`
- Cloud Resource Manager API: `cloudresourcemanager.googleapis.com`
- Cloud Secret Manager API: `secretmanager.googleapis.com`

The [Project Factory module](https://github.com/terraform-google-modules/terraform-google-project-factory) can be used to
provision a project with the necessary APIs enabled.
