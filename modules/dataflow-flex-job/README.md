# Dataflow Flex Template Job Module

This module handles opinionated Dataflow flex template job configuration and deployments.

## Usage

Before using this module, one should get familiar with the `google_dataflow_flex_template_job`’s [Note on "destroy"/"apply"](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dataflow_flex_template_job#note-on-destroy--apply) as the behavior is atypical when compared to other resources.

### Assumption

One assumption is that, before using this module, you already have a working Dataflow flex job template(s) in a GCS location.
If you are not using public IPs, you need to [Configure Private Google Access](https://cloud.google.com/vpc/docs/configure-private-google-access)
on the VPC used by Dataflow.

This is a simple usage:

```hcl
module "dataflow-flex-job" {
  source  = "terraform-google-modules/secured-data-warehouse/google//modules/dataflow-flex-job"
  version = "~> 0.1"

  project_id              = "<project_id>"
  region                  = "us-east4"
  name                    = "dataflow-flex-job-00001"
  container_spec_gcs_path = "gs://<path-to-template>"
  staging_location        = "gs://<gcs_path_staging_data_bucket>"
  temp_location           = "gs://<gcs_path_temp_data_bucket>"
  subnetwork_self_link    = "<subnetwork-self-link>"
  kms_key_name            = "<fully-qualified-kms-key-id>"
  service_account_email   = "<dataflow-controller-service-account-email>"

  parameters = {
    firstParameter  = "ONE",
    secondParameter = "TWO
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| container\_spec\_gcs\_path | The GCS path to the Dataflow job flex template. | `string` | n/a | yes |
| enable\_streaming\_engine | Enable/disable the use of Streaming Engine for the job. Note that Streaming Engine is enabled by default for pipelines developed against the Beam SDK for Python v2.21.0 or later when using Python 3. | `bool` | `true` | no |
| job\_language | Language of the flex template code. Options are 'JAVA' or 'PYTHON'. | `string` | `"JAVA"` | no |
| kms\_key\_name | The name for the Cloud KMS key for the job. Key format is: `projects/PROJECT_ID/locations/LOCATION/keyRings/KEY_RING/cryptoKeys/KEY`. | `string` | n/a | yes |
| max\_workers | The number of workers permitted to work on the job. More workers may improve processing speed at additional cost. | `number` | `1` | no |
| name | The name of the dataflow flex job. | `string` | n/a | yes |
| network\_tags | Network TAGs to be added to the VM instances. Python flex template jobs are only able to set network tags for the launcher VM. For the harness VM it is necessary to configure your firewall rule to use the network tag 'dataflow'. | `list(string)` | `[]` | no |
| on\_delete | One of drain or cancel. Specifies behavior of deletion during terraform destroy. The default is cancel. See https://cloud.google.com/dataflow/docs/guides/stopping-a-pipeline . | `string` | `"cancel"` | no |
| parameters | Key/Value pairs to be passed to the Dataflow job (as used in the template). | `map(any)` | `{}` | no |
| project\_id | The project in which the resource belongs. If it is not provided, the provider project is used. | `string` | n/a | yes |
| region | The region in which the created job should run. | `string` | n/a | yes |
| service\_account\_email | The Service Account email that will be used to identify the VMs in which the jobs are running. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#worker_service_account . | `string` | n/a | yes |
| staging\_location | GCS path for staging code packages needed by workers. | `string` | n/a | yes |
| subnetwork\_self\_link | The subnetwork self link to which VMs will be assigned. | `string` | n/a | yes |
| temp\_location | GCS path for saving temporary workflow jobs. | `string` | n/a | yes |
| use\_public\_ips | If VM instances should used public IPs. | `string` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| job\_id | The unique ID of this job. |
| state | The current state of the resource, selected from the JobState enum. See https://cloud.google.com/dataflow/docs/reference/rest/v1b3/projects.jobs#Job.JobState . |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
