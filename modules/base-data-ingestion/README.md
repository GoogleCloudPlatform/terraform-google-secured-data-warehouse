# Data Ingestion pipeline module

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13.x
- [terraform-provider-google](https://github.com/terraform-providers/terraform-provider-google) plugin ~> v3.30.x

### Configured GCP project

#### Required APIs

The existing project must have the following APIs enabled:

- Access Context Manager API: `accesscontextmanager.googleapis.com`
- Bigquery API: `bigquery.googleapis.com`
- Cloud Billing API: `cloudbilling.googleapis.com`
- Cloud DNS API: `dns.googleapis.com`
- Cloud Pub/Sub API: `pubsub.googleapis.com`
- Cloud Resource Manager API: `cloudresourcemanager.googleapis.com`
- Cloud Storage API: `storage-api.googleapis.com`
- Identity and Access Management (IAM) API: `iam.googleapis.com`
- Service Usage API: `serviceusage.googleapis.com`
- Cloud Data Loss Prevention (DLP) API: `dlp.googleapis.com`
- Cloud Key Management Service (KMS) API: `cloudkms.googleapis.com`

You can use the following command to enable all the APIs, just replace the <project-id> placeholder
with your project id:

```bash
export project_id=<project-id>

gcloud services enable \
cloudresourcemanager.googleapis.com \
storage-api.googleapis.com \
serviceusage.googleapis.com \
dns.googleapis.com \
iam.googleapis.com \
pubsub.googleapis.com \
bigquery.googleapis.com \
accesscontextmanager.googleapis.com \
cloudbilling.googleapis.com \
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
  - Bigquery Admin: `roles/bigquery.admin`
  - Storage Admin: `roles/storage.admin`
  - Pub/Sub Admin: `roles/pubsub.admin`
  - Service Account User: `roles/iam.serviceAccountUser`
  - Create Service Accounts: `roles/iam.serviceAccountCreator`
  - Delete Service Accounts: `roles/iam.serviceAccountDeleter`
  - Service Accounts Token Creator: `roles/iam.serviceAccountTokenCreator`
  - Security Reviewer: `roles/iam.securityReviewer`
  - Compute Network Admin `roles/compute.networkAdmin`
  - Compute Security Admin `roles/compute.securityAdmin`
  - DNS Admin `roles/dns.admin`
- Organization level
  - Billing User: `roles/billing.user`
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
 --role="roles/billing.user"

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
--role="roles/compute.networkAdmin"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/compute.securityAdmin"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/bigquery.admin"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/dns.admin"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/iam.serviceAccountCreator"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/iam.serviceAccountDeleter"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/iam.serviceAccountTokenCreator"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/browser"
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
| bucket\_class | Bucket storage class. | `string` | `"STANDARD"` | no |
| bucket\_lifecycle\_rules | List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches\_storage\_class should be a comma delimited string. | <pre>set(object({<br>    action    = any<br>    condition = any<br>  }))</pre> | <pre>[<br>  {<br>    "action": {<br>      "type": "Delete"<br>    },<br>    "condition": {<br>      "age": 30,<br>      "matches_storage_class": [<br>        "STANDARD"<br>      ],<br>      "with_state": "ANY"<br>    }<br>  }<br>]</pre> | no |
| bucket\_location | Bucket location. | `string` | `"US"` | no |
| bucket\_name | The main part of the name of the bucket to be created. | `string` | n/a | yes |
| cmek\_keyring\_name | The Keyring name for the KMS Customer Managed Encryption Keys. | `string` | n/a | yes |
| cmek\_location | The location for the KMS Customer Managed Encryption Keys. | `string` | n/a | yes |
| data\_governance\_project\_id | The ID of the project in which the data governance resources will be created. | `string` | n/a | yes |
| dataset\_default\_table\_expiration\_ms | TTL of tables using the dataset in MS. The default value is almost 12 months. | `number` | `31536000000` | no |
| dataset\_description | Dataset description. | `string` | `"Ingest dataset"` | no |
| dataset\_id | Unique ID for the dataset being provisioned. | `string` | n/a | yes |
| dataset\_location | The regional location for the dataset only US and EU are allowed in module | `string` | `"US"` | no |
| dataset\_name | Friendly name for the dataset being provisioned. | `string` | `"Ingest dataset"` | no |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_additional\_members | The list additional members to be added on perimeter access. Prefix of group: user: or serviceAccount: is required. | `list(string)` | `[]` | no |
| project\_id | The ID of the project in which the service account will be created. | `string` | n/a | yes |
| region | The region in which the subnetwork will be created. | `string` | `"us-central1"` | no |
| subnet\_ip | The CDIR IP range of the subnetwork. | `string` | n/a | yes |
| terraform\_service\_account | The email address of the service account that will run the Terraform code. | `string` | n/a | yes |
| vpc\_name | the name of the network. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| access\_level\_name | Access context manager access level name |
| cmek\_bigquery\_crypto\_key | The Customer Managed Crypto Key for the BigQuery service. |
| cmek\_ingestion\_crypto\_key | The Customer Managed Crypto Key for the Ingestion crypto boundary. |
| cmek\_keyring\_full\_name | The Keyring full name for the KMS Customer Managed Encryption Keys. |
| cmek\_keyring\_name | The Keyring name for the KMS Customer Managed Encryption Keys. |
| data\_ingest\_bigquery\_dataset | The bigquery dataset created for data ingest pipeline. |
| data\_ingest\_bucket\_names | The name list of the buckets created for data ingest pipeline. |
| data\_ingest\_topic\_name | The topic created for data ingest pipeline. |
| dataflow\_controller\_service\_account\_email | The Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account |
| default\_bigquery\_sa | The default Bigquery service account granted encrypt/decrypt permission on the KMS key. |
| default\_pubsub\_sa | The default Pub/Sub service account granted encrypt/decrypt permission on the KMS key. |
| default\_storage\_sa | The default Storage service account granted encrypt/decrypt permission on the KMS key. |
| network\_name | The name of the VPC being created |
| network\_self\_link | The URI of the VPC being created |
| project\_number | Project number included on perimeter |
| pubsub\_writer\_service\_account\_email | The PubSub writer service account email. Should be used to write data to the PubSub topics the ingestion pipeline reads from. |
| service\_perimeter\_name | Access context manager service perimeter name |
| storage\_writer\_service\_account\_email | The Storage writer service account email. Should be used to write data to the buckets the ingestion pipeline reads from. |
| subnets\_ips | The IPs and CIDRs of the subnets being created |
| subnets\_names | The names of the subnets being created |
| subnets\_regions | The region where the subnets will be created |
| subnets\_self\_links | The self-links of subnets being created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
