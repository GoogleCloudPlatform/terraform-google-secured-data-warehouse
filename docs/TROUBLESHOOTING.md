# Troubleshooting

## Issues

- [Unable to open the staging file](#unable-to-open-the-staging-file)
- [Usar vpc](#usar-vpc)
- [Egress](#egress)
- [Se adicionar na lista de perimeters](#se-adicionar-na-lista-de-perimeters)


### Unable to open the staging file

**Error message:**


```
Failed to read the result file : gs://<BUCKET-NAME>/staging/template_launches/ 2021-12-06_04_37_18-105494327517795773/ operation_result with error message: (59b58cff2e1b7caf): Unable to open template file: gs://<BUCKET-NAME>/staging/template_launches/ 2021-12-06_04_37_18-105494327517795773/ operation_result..
```

**Cause:**

You did not use one of the Service Accounts created on the main module to be used as the Dataflow Worker Service Account.

If you do not specify one in the parameters, the Dataflow job always use the default [Dataflow Service Account](https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#security_and_permissions_for_pipelines_on).

**Solution:**

You must use one of the Service Accounts created on the main module.

- Data ingestion:
  - Module output: `dataflow_controller_service_account_email`
  - Email format: `sa-dataflow-controller@<DATA-INGESTION-PROJECT-ID>.iam.gserviceaccount.com`
- Confidential Data:
  - Module output: `confidential_dataflow_controller_service_account_email`
  - Email format: `sa-dataflow-controller-reid@<CONFIDENTIAL-DATA-PROJECT-ID>.iam.gserviceaccount.com`

The Service Account must be declared as a job parameter.
- Console:
  - Use the optional parameter `Service account email`.
- Gcloud:
  - Use the optional flag [--service-account-email](https://cloud.google.com/sdk/gcloud/reference/dataflow/jobs/run#--service-account-email).
- Terraform:
  - Use the input `service_account_email` from the [Dataflow Flex Job Module](../modules/dataflow-flex-job/README.md#inputs).





### Usar vpc

**Error message:**

```
Failed to start the VM, launcher-2021120604300713065380799072320283, used for launching because of status code: INVALID_ARGUMENT, reason: Error: Message: Invalid value for field 'resource.networkInterfaces[0].network': 'global/networks/default'. The referenced network resource cannot be found. HTTP Code: 400.
```

**Cause:**

This message means you have reached your [project creation quota](https://support.google.com/cloud/answer/6330231).

**Solution:**

In this case, you can use the [Request Project Quota Increase](https://support.google.com/code/contact/project_quota_increase)
form to request a quota increase.

In the support form,
for the field **Email addresses that will be used to create projects**,
use the email address of `terraform_service_account` that is created by the Terraform Example Foundation 0-bootstrap step.

**Notes:**

- If you see other quota errors, see the [Quota documentation](https://cloud.google.com/docs/quota).

### Egress

**Error message:**

```
The metadata file for this template coukd not be parsed.
    VIEW DETAILS
```
In `VIEW DETAILS`:
```
Fail to process as Flex Template and Legacy Template. Flex Template Process result:(390ac373ef6bcb87): Template file failed to load: gs://bkt-ci-sdw-ext-flx-235c70-61e9-tpl-b9c1/flex-template-samples/regional-bq-dlp-bq-streaming.json. Permissions denied. Request is prohibited by organization's policy. vpcServiceControlsUniqueIdentifier: UkMfebL5M8PxBH2MtCok1uzicBVh3ijxggZ_f9HxQWPQB1mVPNCC, Legacy Template Process result:(390ac373ef6bc2a5): Template file failed to load: gs://bkt-ci-sdw-ext-flx-235c70-61e9-tpl-b9c1/flex-template-samples/regional-bq-dlp-bq-streaming.json_metadata. Permissions denied. Request is prohibited by organization's policy. vpcServiceControlsUniqueIdentifier: R0K-N1zbfk05YDsZQDW5DqZftkGP-NjQLAdJiH4FoEMy7oVtnXdr
```
```
Fail to process as Flex Template and Legacy Template. Flex Template Process result:(390ac373ef6bcb87): Template file failed to load: <gcs_template_path>. Permissions denied. Request is prohibited by organization's policy. vpcServiceControlsUniqueIdentifier: <unique_identifier>, Legacy Template Process result:(390ac373ef6bc2a5): Template file failed to load: <gcs_template_path>. Permissions denied. Request is prohibited by organization's policy. vpcServiceControlsUniqueIdentifier: <unique_identifier>
```

**Cause:**

This message means you have reached your [project creation quota](https://support.google.com/cloud/answer/6330231).

**Solution:**

In this case, you can use the [Request Project Quota Increase](https://support.google.com/code/contact/project_quota_increase)
form to request a quota increase.

In the support form,
for the field **Email addresses that will be used to create projects**,
use the email address of `terraform_service_account` that is created by the Terraform Example Foundation 0-bootstrap step.

**Notes:**

- If you see other quota errors, see the [Quota documentation](https://cloud.google.com/docs/quota).

### Se adicionar na lista de perimeters

**Error message:**

```
COLOCAR O ERRO
```

**Cause:**

This message means you have reached your [project creation quota](https://support.google.com/cloud/answer/6330231).

**Solution:**

In this case, you can use the [Request Project Quota Increase](https://support.google.com/code/contact/project_quota_increase)
form to request a quota increase.

In the support form,
for the field **Email addresses that will be used to create projects**,
use the email address of `terraform_service_account` that is created by the Terraform Example Foundation 0-bootstrap step.

**Notes:**

- If you see other quota errors, see the [Quota documentation](https://cloud.google.com/docs/quota).