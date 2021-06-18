# Simple Example

This example illustrates how to use the `data_governance` sub module.

To provision this example, do the following from within this directory:

1. Create a key and secret:
   ```
   head -c 32 /dev/urandom | base64 | gcloud secrets create ORIGINAL_KEY_SECRET_NAME \
   --project PROJECT_ID_SECRET_MGR \
   --replication-policy=automatic \
   --data-file=-
   ```
1. Get terraform plugins
   ```
   terraform init
   ```
1. See the infrastructure plan. You will be asked about the `project_id`, `terraform_service_account`, and `original_key_secret_name`
   ```
   terraform plan
   ```
1. After reviewing the plan, apply the infrastructure plan
   ```
   terraform apply
   ```
1. After you are done with the example, destroy the built infrastructure
   ```
   terraform destroy
   ```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| original\_key\_secret\_name | Name of the secret used to hold a user provided key for encryption. | `string` | n/a | yes |
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |
| project\_id\_secret\_mgr | ID of the project that hosts the Secret Manager service being used. | `string` | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| keyring | The name of the keyring. |
| keys | List of created key names. |
| location | The location of the keyring. |
| template\_id | ID of the DLP de-identification template created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
