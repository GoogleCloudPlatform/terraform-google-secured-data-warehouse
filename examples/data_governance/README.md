# Simple Example

This example illustrates how to use the `data_governance` submodule.

**Note:** Contact your Security Team to obtain the `crypto_key` and `wrapped_key` pair.
The `crypto_key` location must be the same location used for the `dlp_location`.

To provision this example, complete these tasks from within this directory:

1. Initialize the directory:
   ```
   terraform init
   ```
1. Review the infrastructure plan. When prompted, enter the `project_id`, `terraform_service_account`, `dlp_location`, `crypto_key` and `wrapped_key`
   ```
   terraform plan
   ```
1. After reviewing the plan, apply it:
   ```
   terraform apply
   ```
1. After you are done with the example, destroy the built infrastructure:
   ```
   terraform destroy
   ```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| crypto\_key | The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP. | `string` | n/a | yes |
| dlp\_location | The location of DLP resources. See https://cloud.google.com/dlp/docs/locations. The 'global' KMS location is valid. | `string` | n/a | yes |
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |
| terraform\_service\_account | The email address of the service account that will run the Terraform config. | `string` | n/a | yes |
| wrapped\_key | The base64 encoded data crypto key wrapped by KMS. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dlp\_location | The location of the DLP resources. |
| template\_id | The ID of the Cloud DLP de-identification template that is created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
