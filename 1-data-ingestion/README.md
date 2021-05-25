# Data Ingestion pipeline module

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13.x
- [terraform-provider-google](https://github.com/terraform-providers/terraform-provider-google) plugin ~> v3.30.x

### Configured GCP project

#### Required APIs

The existing project must have the following APIs enabled:

- Access Context Manager API: `accesscontextmanager.googleapis.com`
- Compute Engine: `compute.googleapis.com`
- Cloud Asset API: `cloudasset.googleapis.com`
- Cloud Build API: `cloudbuild.googleapis.com`
- Cloud DNS API: `dns.googleapis.com`
- Cloud Functions API: `cloudfunctions.googleapis.com`
- Cloud Logging API: `logging.googleapis.com`
- Cloud Monitoring API: `monitoring.googleapis.com`
- Cloud Pub/Sub API: `pubsub.googleapis.com`
- Cloud Resource Manager API: `cloudresourcemanager.googleapis.com`
- Cloud Storage API: `storage-component.googleapis.com`
- Identity and Access Management (IAM) API: `iam.googleapis.com`
- Serverless VPC Access API: `vpcaccess.googleapis.com`
- Service Usage API: `serviceusage.googleapis.com`
- Security Command Center API: `securitycenter.googleapis.com`

You can use the following command to enable all the APIs, just replace the <project-id> placeholder
with your project id:

```bash
export project_id=<project-id>

gcloud services enable \
accesscontextmanager.googleapis.com \
cloudasset.googleapis.com \
cloudbuild.googleapis.com \
cloudfunctions.googleapis.com \
cloudresourcemanager.googleapis.com \
compute.googleapis.com \
dns.googleapis.com \
iam.googleapis.com \
logging.googleapis.com \
pubsub.googleapis.com \
securitycenter.googleapis.com \
serviceusage.googleapis.com \
storage-component.googleapis.com \
vpcaccess.googleapis.com \
monitoring.googleapis.com \
--project ${project_id}
```
### GCP user account

A user to run this code impersonating a service account with the following IAM roles:

- Project level:
  - Service Account User: `roles/iam.serviceAccountUser`
  - Service Account Token Creator: `roles/iam.serviceAccountTokenCreator`

You can use the following command to grant these roles, just replace the <project-id> placeholder
with your project id and <your-email-account> with your account:

```bash
export project_id=<project-id>
export user_account=<your-email-account>

gcloud projects add-iam-policy-binding ${project_id} \
--member="user:${user_account}" \
--role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding ${project_id} \
--member="user:${user_account}" \
--role="roles/iam.serviceAccountTokenCreator"
```

#### A service account to run terraform

The Service Account which will be used to invoke this module must have the following IAM roles:

- Project level:
  - Storage Admin: `roles/storage.admin`
  - Pub/Sub Admin: `roles/pubsub.admin`
  - Service Account User: `roles/iam.serviceAccountUser`
  - Create Service Accounts: `roles/iam.serviceAccountCreator`
  - Delete Service Accounts: `roles/iam.serviceAccountDeleter`
  - Security Reviewer: `roles/iam.securityReviewer`
  - Compute Network Admin `roles/compute.networkAdmin`
  - Compute Security Admin `roles/compute.securityAdmin`
  - DNS Admin `roles/dns.admin`
- Organization level
  - Organization Policy Administrator: `roles/orgpolicy.policyAdmin`
  - Access Context Manager Admin: `roles/accesscontextmanager.policyAdmin`
  - Organization Administrator: `roles/resourcemanager.organizationAdmin`
  - Organization Shared VPC Admin: `roles/compute.xpnAdmin`
  - VPC Access Admin: `roles/vpcaccess.admin`

You can use the following command to grant these roles, just replace the placeholders with the correct values.

```bash
export project_id=<project-id>
export organization_id=<organization-id>
export sa_email=<service-account-email>

gcloud organizations add-iam-policy-binding ${organization_id} \
 --member="serviceAccount:${sa_email}" \
 --role="roles/orgpolicy.policyAdmin"

gcloud organizations add-iam-policy-binding ${organization_id} \
 --member="serviceAccount:${sa_email}" \
 --role="roles/accesscontextmanager.policyAdmin"

gcloud organizations add-iam-policy-binding ${organization_id} \
 --member="serviceAccount:${sa_email}" \
 --role="roles/resourcemanager.organizationAdmin"

gcloud organizations add-iam-policy-binding ${organization_id} \
 --member="serviceAccount:${sa_email}" \
 --role="roles/compute.xpnAdmin"

gcloud organizations add-iam-policy-binding ${organization_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/vpcaccess.admin"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/storage.admin"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/pubsub.admin"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/logging.configWriter"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/iam.serviceAccountCreator"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/iam.serviceAccountDeleter"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/iam.securityReviewer"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/compute.networkAdmin"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/compute.securityAdmin"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/dns.admin"
```
#### Assign Cloud Storage to the logging Bucket

You need a bucket already created to store objects access logging.
You may need to configure some access for this bucket, and you can find more
information [here](https://cloud.google.com/storage/docs/access-logs).

The only step to be done manually, is provide Cloud Storage the `roles/storage.legacyBucketWriter` role for the bucket. Terraform will enable logging during bucket creation.

__Note:__ If you have [Domain Restricted Sharing](https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains) enabled on your organization, you will need to temporally disable it to run the command bellow. Enable it again after running the command.

```
gsutil iam ch group:cloud-storage-analytics@google.com:legacyBucketWriter gs://<YOUR-LOGGING-BUCKET>
```

#### Set up Access Policy Context Policy

Obtain the value for the `access_context_manager_policy_id` variable. It can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION-ID --format="value(name)"`.

If the command return no value, you will need to [create the access context manager policy](https://cloud.google.com/access-context-manager/docs/create-access-policy) for the organization.

```
gcloud access-context-manager policies create \
--organization YOUR-ORGANIZATION-ID --title POLICY_TITLE
```

**Troubleshooting:**
If your user does not have the necessary roles to run the commands above you can [impersonate](https://cloud.google.com/iam/docs/impersonating-service-accounts) the terraform service account that will be used in the deploy by appending `--impersonate-service-account=<sa-email>` to the commands to be run.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `number` | n/a | yes |
| bucket\_location | Bucket location. | `string` | `"EU"` | no |
| bucket\_name | The main part of the name of the bucket to be created. | `string` | n/a | yes |
| dataset\_default\_table\_expiration\_ms | TTL of tables using the dataset in MS | `number` | `31536000000` | no |
| dataset\_description | Dataset description. | `string` | `"Ingest dataset"` | no |
| dataset\_id | Unique ID for the dataset being provisioned. | `string` | n/a | yes |
| dataset\_location | The regional location for the dataset only US and EU are allowed in module | `string` | `"US"` | no |
| dataset\_name | Friendly name for the dataset being provisioned. | `string` | `"Ingest dataset"` | no |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_additional\_members | The list additional members to be added on perimeter access. Prefix of group: user: or serviceAccount: is required. | `list(string)` | `[]` | no |
| project\_id | The ID of the project in which the service account will be created. | `string` | n/a | yes |
| region | The region in which the subnetwork will be created. | `string` | n/a | yes |
| subnet\_ip | The CDIR IP range of the subnetwork. | `string` | `"10.0.32.0/21"` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |
| vpc\_name | the name of the network. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| access\_level\_name | Access context manager access level name |
| data\_ingest\_bigquery\_dataset | The bigquery dataset created for data ingest pipeline. |
| data\_ingest\_bucket\_names | The name list of the buckets created for data ingest pipeline. |
| data\_ingest\_topic\_name | The topic created for data ingest pipeline. |
| dataflow\_controller\_service\_account\_email | The service account email. |
| network\_name | The name of the VPC being created |
| network\_self\_link | The URI of the VPC being created |
| pubsub\_writer\_service\_account\_email | The service account email. |
| service\_perimeter\_name | Access context manager service perimeter name |
| storage\_writer\_service\_account\_email | The service account email. |
| subnets\_ips | The IPs and CIDRs of the subnets being created |
| subnets\_names | The names of the subnets being created |
| subnets\_regions | The region where the subnets will be created |
| subnets\_self\_links | The self-links of subnets being created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->