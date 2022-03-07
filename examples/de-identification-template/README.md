# De-identification template submodule example

This example illustrates how to use the [de-identification template](../../modules/de-identification-template/README.md) submodule.

## Prerequisites

1. The [De-identification template](../../modules/de-identification-template/README.md#requirements) submodule requirements to using the submodule.
1. A `crypto_key` and `wrapped_key` pair. Contact your Security Team to obtain the `crypto_key` and `wrapped_key` pair.
The `crypto_key` location must be the same location used for the `dlp_location`.
There is a [Wrapped Key Helper](../../helpers/wrapped-key/README.md) python script which generates a wrapped key.
1. The identity deploying the example must have permission to grant roles "roles/cloudkms.cryptoKeyDecrypter" and "roles/cloudkms.cryptoKeyEncrypter" in the KMS `crypto_key`. It will be granted to the `dataflow_service_account`.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| crypto\_key | The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP. | `string` | n/a | yes |
| dataflow\_service\_account | The Service Account email that will be used to identify the VMs in which the jobs are running. | `string` | n/a | yes |
| labels | (Optional) Default label used by Data Warehouse resources. | `map(string)` | <pre>{<br>  "environment": "default"<br>}</pre> | no |
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |
| terraform\_service\_account | The email address of the service account that will run the Terraform config. | `string` | n/a | yes |
| wrapped\_key | The base64 encoded data crypto key wrapped by KMS. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| template\_id | The ID of the Cloud DLP de-identification template that is created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
