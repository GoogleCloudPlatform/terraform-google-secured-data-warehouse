# Org policy submodule
This module creates the guard rails needed to protect the environment.

These controls are more horizontal focused, applying more broadly to an environment.

This creates the following:
* org policies

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_secured\_data\_warehouse | The project for the secured data warehouse. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| folder\_trusted | Folder that holds all the trusted projects and constraints |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
