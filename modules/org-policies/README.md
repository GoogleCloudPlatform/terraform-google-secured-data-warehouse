# Service account submodule
This module creates org policies.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_secured_data_warehouse | project name for secured data warehouse | `string` | n/a | yes |
| trusted_private_subnet | This list constraint defines the set of shared VPC subnetworks that eligible resources can use. | `string` | n/a | yes |
