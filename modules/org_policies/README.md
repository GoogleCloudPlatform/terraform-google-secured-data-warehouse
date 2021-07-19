# Org policy submodule
This module creates the guard rails needed to protect the environment.

These controls are more horizontal focused, applying more broadly to an environment.

This creates the following:
* org policies

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_secured\_data\_warehouse | The project id for the secured data warehouse. | `string` | n/a | yes |
| region | The region in which the subnetwork resides. | `string` | n/a | yes |
| trusted\_locations | This is a list of trusted regions where location-based GCP resources can be created. ie us-locations eu-locations | `list(string)` | <pre>[<br>  "us-locations",<br>  "eu-locations"<br>]</pre> | no |
| trusted\_subnetwork | Subnetwork name that eligible resources can use. | `string` | n/a | yes |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
