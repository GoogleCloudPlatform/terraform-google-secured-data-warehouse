# Dataflow with DLP de-identification

This example illustrates how to run a Dataflow job that uses the `de_identification_template` submodule with the `1-data-ingestion` step.

## Prerequisites

1. 1-data-ingestion executed successfully.
2. A `crypto_key` and `wrapped_key` pair.  Contact your Security Team to obtain the pair. The `crypto_key` location must be the same location used for the `dlp_location`.

## Usage

To provision this example, complete these tasks from within this directory:

1. Initialize the directory:
   ```
   terraform init
   ```
1. Review the infrastructure plan. When prompted, enter the `project_id`, `terraform_service_account`, `network_self_link`, `subnetwork_self_link`, `dataset_id`, `dlp_location`, `crypto_key` and `wrapped_key`
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
| bucket\_force\_destroy | When deleting a bucket, this boolean option will delete all contained objects. If you try to delete a bucket that contains objects, Terraform will fail that run. | `bool` | `false` | no |
| bucket\_lifecycle\_rules | List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches\_storage\_class should be a comma delimited string. | <pre>set(object({<br>    action    = map(string)<br>    condition = map(string)<br>  }))</pre> | <pre>[<br>  {<br>    "action": {<br>      "type": "Delete"<br>    },<br>    "condition": {<br>      "age": 30,<br>      "with_state": "ANY"<br>    }<br>  }<br>]</pre> | no |
| bucket\_location | Bucket location. | `string` | `"US"` | no |
| bucket\_name | The main part of the name of the bucket to be created. | `string` | n/a | yes |
| change\_sample\_file\_encoding | Flag to decide if the encoding of the the sample file should be converted to UTF-8. | `string` | `"true"` | no |
| crypto\_key | The full resource name of the Cloud KMS key that wraps the data crypto key used by DLP. | `string` | n/a | yes |
| dataflow\_service\_account | The Service Account email that will be used to identify the VMs in which the jobs are running | `string` | n/a | yes |
| dataset\_id | Unique ID for the dataset being provisioned. | `string` | n/a | yes |
| dlp\_location | The location of DLP resources. See https://cloud.google.com/dlp/docs/locations. The 'global' KMS location is valid. | `string` | `"global"` | no |
| ip\_configuration | The configuration for VM IPs. Options are 'WORKER\_IP\_PUBLIC' or 'WORKER\_IP\_PRIVATE'. | `string` | `"WORKER_IP_PRIVATE"` | no |
| network\_self\_link | The network self link to which VMs will be assigned. | `string` | n/a | yes |
| project\_id | The ID of the project in which the service account will be created. | `string` | n/a | yes |
| region | The region in which the subnetwork will be created. | `string` | `"us-central1"` | no |
| sample\_file\_original\_encoding | (Optional) The original encoding of the sample file. | `string` | `"ISO-8859-1"` | no |
| subnetwork\_self\_link | The subnetwork self link to which VMs will be assigned. | `string` | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |
| wrapped\_key | The base64 encoded data crypto key wrapped by KMS. | `string` | n/a | yes |
| zone | The zone in which the created job should run. | `string` | `"us-central1-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_name | The name of the bucket |
| controller\_service\_account | The Service Account email that will be used to identify the VMs in which the jobs are running |
| df\_job\_id | The unique Id of the newly created Dataflow job |
| df\_job\_name | The name of the newly created Dataflow job |
| df\_job\_region | The region of the newly created Dataflow job |
| df\_job\_state | The state of the newly created Dataflow job |
| dlp\_location | The location of the DLP resources. |
| project\_id | The project's ID |
| template\_id | The ID of the Cloud DLP de-identification template that is created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
