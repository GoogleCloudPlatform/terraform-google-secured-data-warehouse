# Regional Python Flex Template

This example illustrates how to run a Flex Python Dataflow job. It uses:

- The `base-data-ingestion` submodule to create the basic ingestion infrastructure,
- The `de_identification_template` submodule to create the DLP template,
- The `flex_template` submodule to build a fllex Python template,
- The `python_module_repository` submodule to host a private Python Module repository

## VirtualEnv

We recommend running this example inside of a [Python virtual environment](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/) to avoid installing extra packages in your Python default environment.

After installing virtual env by following the link above, create a new Python environment by running:

```sh
python3 -m venv /tmp/python_flex_template
```

Finally, activate it:

```sh
source /tmp/python_flex_template/bin/activate
```

## Prerequisites

1. A `crypto_key` and `wrapped_key` pair.  Contact your Security Team to obtain the pair. The `crypto_key` location must be the same location used for the `location` variable.
1. An Existing GCP Project

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13.x
- [terraform-provider-google](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_versions#google) plugin ~> v3.77.x
- [terraform-provider-google beta](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_versions#google-beta) plugin ~> v3.77.x
- [Python] ~> 3.7
- [unzip]
- [tar]

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
- Artifact Registry API: `artifactregistry.googleapis.com`
- Cloud Build API: `cloudbuild.googleapis.com`
- Compute Engine API: `compute.googleapis.com`
- Google Cloud Dataflow API: `dataflow.googleapis.com`

You can use the following command to enable all the APIs, just replace the <project-id> placeholder
with your project id:

```bash
export project_id=<project-id>

gcloud services enable \
cloudresourcemanager.googleapis.com \
compute.googleapis.com \
storage-api.googleapis.com \
serviceusage.googleapis.com \
dns.googleapis.com \
iam.googleapis.com \
pubsub.googleapis.com \
bigquery.googleapis.com \
accesscontextmanager.googleapis.com \
dlp.googleapis.com \
cloudkms.googleapis.com \
cloudbilling.googleapis.com \
artifactregistry.googleapis.com \
cloudbuild.googleapis.com \
dataflow.googleapis.com \
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
  - Compute Network Admin: `roles/compute.networkAdmin`
  - Compute Security Admin: `roles/compute.securityAdmin`
  - DNS Admin: `roles/dns.admin`
  - Cloud Build Editor: `roles/cloudbuild.builds.editor`
  - Artifact Registry Administrator: `roles/artifactregistry.admin`
  - Cloud KMS Admin: `roles/cloudkms.admin`
  - Dataflow Developer: `roles/dataflow.developer`
  - DLP User: `roles/dlp.user`
  - DLP De-identify Templates Editor: `roles/dlp.deidentifyTemplatesEditor`
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

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/cloudbuild.builds.editor"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/artifactregistry.admin"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/cloudkms.admin"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/dataflow.developer"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/dlp.deidentifyTemplatesEditor"

gcloud projects add-iam-policy-binding ${project_id} \
--member="serviceAccount:${sa_email}" \
--role="roles/dlp.user"
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
| location | The location of Artifact registry. Run `gcloud artifacts locations list` to list available locations. | `string` | `"us-central1"` | no |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_additional\_members | The list additional members to be added on perimeter access. Prefix of group: user: or serviceAccount: is required. | `list(string)` | `[]` | no |
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |
| terraform\_service\_account | The email address of the service account that will run the Terraform config. | `string` | n/a | yes |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
