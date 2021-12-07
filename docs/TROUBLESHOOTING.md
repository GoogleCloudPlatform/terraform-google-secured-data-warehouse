# Troubleshooting

## Issues

- [Unable to open the staging file](#unable-to-open-the-staging-file)
- [The referenced network resource cannot be found](#the-referenced-network-resource-cannot-be-found)
- [Template file failed to load](#template-file-failed-to-load)
- [The server was only able to partially fulfill your request](#the-server-was-only-able-to-partially-fulfill-your-request)

### Unable to open the staging file

This error message is shown on the `Job Logs` when trying to run the job on the console.

**Error message:**

```console
Failed to read the result file : gs://<BUCKET-NAME>/staging/template_launches/ 2021-12-06_04_37_18-105494327517795773/
operation_result with error message: (59b58cff2e1b7caf): Unable to open template file:
gs://<BUCKET-NAME>/staging/template_launches/ 2021-12-06_04_37_18-105494327517795773/ operation_result..
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

The `Service Account` must be declared as a job parameter.

- **Console**: Use the optional parameter `Service account email`.
- **Gcloud**: Use the optional flag [--service-account-email](https://cloud.google.com/sdk/gcloud/reference/dataflow/jobs/run#--service-account-email).
- **Terraform**: Use the input `service_account_email` from the [Dataflow Flex Job Module](../modules/dataflow-flex-job/README.md#inputs).

### The referenced network resource cannot be found

This error message is shown on the `Job Logs` when trying to run the job on the console.

**Error message:**

```console
Failed to start the VM, launcher-2021120604300713065380799072320283, used for launching because of status code: INVALID_ARGUMENT, reason:
Error: Message: Invalid value for field 'resource.networkInterfaces[0].network': 'global/networks/default'.
The referenced network resource cannot be found. HTTP Code: 400.
```

**Cause:**

If you do not specify a **subnetwork** in the job parameters, Dataflow will use the [default VPC subnetwork](https://cloud.google.com/dataflow/docs/guides/specifying-networks#specifying_a_network_and_a_subnetwork) to deploy the Job.
If the default network does not exist you will get the 400 error.

**Solution:**

A valid `VPC subnetwork` must be declared as a job parameter in the creation of the Dataflow Job.

- **Console**: Use the optional parameter `Subnetwork`.
- **Gcloud CLI**: Use the optional flag [--subnetwork](https://cloud.google.com/sdk/gcloud/reference/dataflow/jobs/run#--subnetwork).
- **Terraform**: Use the input `subnetwork_self_link` from the [Dataflow Flex Job Module](../modules/dataflow-flex-job/README.md#inputs).

### Template file failed to load

This error message is shown on the `GCP Console` when trying to create a new job.

**Error message:**

```console
The metadata file for this template could not be parsed.
    VIEW DETAILS
```

In `VIEW DETAILS`:

```console
Fail to process as Flex Template and Legacy Template. Flex Template Process result:(390ac373ef6bcb87):
Template file failed to load: gs://<BUCKET-NAME>/flex-template-samples/regional-bq-dlp-bq-streaming.json.
Permissions denied. Request is prohibited by organization's policy. vpcServiceControlsUniqueIdentifier: <UNIQUE-IDENTIFIER>,
Legacy Template Process result:(390ac373ef6bc2a5): Template file failed to load: gs://<BUCKET-NAME>/flex-template-samples/regional-bq-dlp-bq-streaming.json.
Permissions denied. Request is prohibited by organization's policy. vpcServiceControlsUniqueIdentifier: <UNIQUE-IDENTIFIER>
```

**Cause:**

One of the perimeters `confidential` or `data ingestion` do not allow external access asked to fetch the template file.

**Solution:**

Any user that need access for a external template must be specified:

- For the `confidential perimeter` use the `confidential_data_dataflow_deployer_identities` in the parameter in the [Data Secured Warehouse Module](../README.md#inputs).
- For the `data ingestion perimeter` use the  `data_ingestion_dataflow_deployer_identities` in the parameter in the [Data Secured Warehouse Module](../README.md#inputs).

This will add the user to an egress rule that allow the template to be fetched.

### The server was only able to partially fulfill your request

This error message is shown on the `GCP Console` when trying to view the Dataflow Job created.

**Error message:**

```console
Sorry, the server was only able to partially fulfill your request. Some data might not be rendered.
```

![Dataflow jobs on the GCP console showing the message: Sorry, the server was only able to partially fulfill your request. Some data might not be rendered.](./images/the-server-was-only-able-to-partially-fulfill-your-request.png)

**Cause:**

You are not in the list of members of the access policy associated with the perimeter

**Solution:**

The users that need access in the perimeters must be specified as `perimeter_additional_members` parameter in the [Data Secured Warehouse Module](../README.md#inputs) deploy.

The user that be on the `perimeter_additional_members` list will be added in the members of the access policy associated with the perimeters.
