# De-identification template submodule

This submodule allows you to create a [Cloud Data Loss Prevention](https://cloud.google.com/dlp/docs) (DLP) [de-identification template](https://cloud.google.com/dlp/docs/deidentify-sensitive-data) from a JSON template file that you provide.

## Compatibility

This module is meant for use with Terraform 0.13.

## Usage

Basic usage of this module is as follows:

```hcl
module "de_identification_template" {
  source = "github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse//modules/de_identification_template"

  project_id                = "PROJECT_ID"
  terraform_service_account = "SERVICE_ACCOUNT_EMAIL"
  crypto_key                = "CRYPTO_KEY"
  wrapped_key               = "WRAPPED_KEY"
  dlp_location              = "DLP_LOCATION"
  template_file             = "PATH_TO_TEMPLATE_FILE"
}
```

### DLP de-identification key

Create a base64 encoded data crypto key [wrapped by KMS](https://cloud.google.com/dlp/docs/create-wrapped-key) that you will use to create the Cloud DLP de-identification template.

You will need the wrapped key and the full resource name of the Cloud KMS key that encrypted the data crypto key.

**Note:** Contact your Security Team to obtain the `crypto_key` and `wrapped_key` pair.
The `crypto_key` location must be the same location used for the `dlp_location`.

### Template file

Create a [DLP de-identification](https://cloud.google.com/dlp/docs/deidentify-sensitive-data) template file.

The template file is a JSON representation of a `deidentifyTemplates` call [request body](https://cloud.google.com/dlp/docs/reference/rest/v2/projects.deidentifyTemplates/create#request-body).

You can substitute the following variables in the template file:

- `display_name`: The display name of the DLP template.
- `description`: The description of the DLP template.
- `wrapped_key`: The base64 encoded data crypto key wrapped by the Cloud KMS `crypto_key`.
- `crypto_key`: The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP.
- `template_id`: The template ID, composed by the variable `template_id_prefix` and a random suffix.

See the Terraform [templatefile](https://www.terraform.io/docs/language/functions/templatefile.html) function documentation and
the [sample template file](../../examples/de_identification_template/deidentification.tmpl) in the examples folder for details on how substitutions are handled.

Because you provide the de-identification template, you can choose the type of transformation:

- For unstructured text, use [Info Type Transformation](https://cloud.google.com/dlp/docs/reference/rest/v2/projects.deidentifyTemplates#DeidentifyTemplate.InfoTypeTransformations).
- For structured data, use [Record Transformation](https://cloud.google.com/dlp/docs/reference/rest/v2/projects.deidentifyTemplates#DeidentifyTemplate.RecordTransformations) for structured data.

A functional example for a Record Transformation is included under the
[examples/de_identification_template](./examples/de_identification_template/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| crypto\_key | The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP. | `string` | n/a | yes |
| dlp\_location | The location of DLP resources. See https://cloud.google.com/dlp/docs/locations. The 'global' KMS location is valid. | `string` | n/a | yes |
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |
| template\_description | A description for the DLP de-identification template. | `string` | `"De-identifies sensitive content defined in the template with a KMS wrapped CMEK."` | no |
| template\_display\_name | The display name of the DLP de-identification template. | `string` | `"De-identification template using a KMS wrapped CMEK"` | no |
| template\_file | the path to the DLP de-identification template file. | `string` | n/a | yes |
| template\_id\_prefix | Prefix to be used in the creation of the ID of the DLP de-identification template. | `string` | `"de_identification"` | no |
| terraform\_service\_account | The email address of the service account that will run the Terraform config. | `string` | n/a | yes |
| wrapped\_key | The base64 encoded data crypto key wrapped by KMS. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| crypto\_key | The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP. |
| dlp\_location | The location of the DLP resources. |
| template\_description | Description of the DLP de-identification template. |
| template\_display\_name | Display name of the DLP de-identification template. |
| template\_id | The ID of the Cloud DLP de-identification template that is created. |
| wrapped\_key | The base64 encoded data crypto key wrapped by KMS. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe the requirements for using this module.

### Software

Install the following dependencies:

- [gcloud SDK](https://cloud.google.com/sdk/install) >= 281.0.0
- [Terraform](https://www.terraform.io/downloads.html) >= 0.13.0
- [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) plugin >= 3.67.0
- [Terraform Provider Beta for GCP](https://github.com/terraform-providers/terraform-provider-google) plugin >= 3.67.0
- [curl](https://curl.haxx.se/)

### Service Account

Create a [service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts) with the following roles to provision the resources for this module:

- Cloud KMS Admin: `roles/cloudkms.admin`
- DLP De-identify Templates Editor: `roles/dlp.deidentifyTemplatesEditor`
- DLP Inspect Templates Editor: `roles/dlp.inspectTemplatesEditor`
- DLP User: `roles/dlp.user`
- Service Account Token Creator: `roles/iam.serviceAccountTokenCreator`

### APIs

Create a [project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) with the following APIs enabled to host the resources for this module:

- Cloud Key Management Service API: `cloudkms.googleapis.com`
- Cloud Data Loss Prevention API: `dlp.googleapis.com`
- Cloud Identity and Access Management API: `iam.googleapis.com`
- Cloud Resource Manager API: `cloudresourcemanager.googleapis.com`

You can use the [Project Factory module](https://github.com/terraform-google-modules/terraform-google-project-factory) to provision a project with the necessary APIs enabled.

To provision the service account, you can use the [IAM module](https://github.com/terraform-google-modules/terraform-google-iam) in combination with the Project Factory module.
