# Simple Example

This example illustrates how to use the `data_governance` submodule.

**Note:** In a real context, the key stored in the secret should be provided by your security team.

To provision this example, complete these tasks from within this directory:

1. Create a key and a secret:
   ```
   head -c 32 /dev/urandom | base64 | gcloud secrets create ORIGINAL_KEY_SECRET_NAME \
   --project PROJECT_ID_SECRET_MGR \
   --replication-policy=automatic \
   --data-file=-
   ```
1. Initialize the directory:
   ```
   terraform init
   ```
1. Review the infrastructure plan. When prompted, enter the `project_id`, `terraform_service_account`, and `original_key_secret_name`
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
| crypto\_key | Crypto key used to wrap the wrapped key. | `string` | n/a | yes |
| dlp\_location | The location of DLP resources. See https://cloud.google.com/dlp/docs/locations. The 'global' KMS location is valid. | `string` | n/a | yes |
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |
| wrapped\_key | The Wrapped key. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dlp\_location | The location of the DLP resources. |
| template\_id | ID of the DLP de-identification template created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
