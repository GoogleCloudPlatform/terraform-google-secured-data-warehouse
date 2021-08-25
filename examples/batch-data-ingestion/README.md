# Batch Dataflow with DLP de-identification

This example illustrates how to run a Dataflow job that uses the `batch templates with DLP` submodule with the `base-data-ingestion` submodule.

## Requirements

1. A project previusly created, with [Google App Engine Application Enabled](https://cloud.google.com/scheduler/docs/quickstart#create_a_project_with_an_app_engine_app).
1. A `crypto_key` and `wrapped_key` pair.  Contact your Security Team to obtain the pair. The `crypto_key` location must be the same location used for the `dlp_location`.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `number` | n/a | yes |
| bucket\_force\_destroy | When deleting a bucket, this boolean option will delete all contained objects. If you try to delete a bucket that contains objects, Terraform will fail that run. | `bool` | `false` | no |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_members | The list of all members to be added on perimeter access. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required. | `list(string)` | n/a | yes |
| project\_id | The ID of the project in which the service account will be created. | `string` | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| controller\_service\_account | The Service Account email that will be used to identify the VMs in which the jobs are running. |
| dataflow\_temp\_bucket\_name | The name of the dataflow temporary bucket. |
| df\_job\_network | The URI of the VPC being created. |
| df\_job\_region | The region of the newly created Dataflow job. |
| df\_job\_subnetwork | The name of the subnetwork used for create Dataflow job. |
| project\_id | The project's ID. |
| scheduler\_id | Cloud Scheduler Job id created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
