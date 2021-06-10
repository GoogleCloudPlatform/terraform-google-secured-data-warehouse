# Simple Example

This example illustrates how to use the `data_governance` sub module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| keyring | The name of the keyring. |
| keys | List of created key names. |
| location | The location of the keyring. |
| template\_id | ID of the DLP de-identification template created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
