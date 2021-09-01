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
| bucket\_logging\_location | The ID of the project in which the data governance resources will be created. | `string` | n/a | yes |
| bucket\_logging\_name | The location of the bucket that will store the logs. | `string` | n/a | yes |
| kms\_key\_name | The kms key that will be used to encrypt the bucket. | `string` | n/a | yes |
| logging\_project\_id | The name of the bucket that will store the logs | `string` | n/a | yes |
| projects\_ids | The project IDs that will be export the logs. | `list(string)` | n/a | yes |
| sink\_filter | The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| sinks | The list of sink that were created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
