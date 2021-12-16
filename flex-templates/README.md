# Flex Templates Samples

These are Dataflow [Flex Template](https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates) samples that can be used to validate the flow of data in the Secured Data Warehouse Blueprint.

In this folder we have:

- A [terraform infrastructure script](./template-artifact-storage) to create a pair of a Docker Artifact Registry Repository and a Google Cloud Storage Bucket to store the flex templates and a Python Artifact Registry Repository to host Python modules needed by the Python flex templates when they are staged by dataflow.
- A folder for [Python](./python/) code samples for de-identification and re-identification
- In the Python folder we also have a [Cloud build file](./python/modules/cloudbuild.yaml) to populate the Python Artifact Registry Repository.

The Secured Data Warehouse Blueprint main module [creates](../README.md#outputs) two user-managed Dataflow [controller service accounts](https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_worker_service_account).
These service accounts are used to stage and run the Dataflow job.

To be able to deploy this Flex template you need to grant to the Dataflow controller service account the following roles in the resources created in the infrastructure script:

- Artifact Registry Reader (`roles/artifactregistry.reader`) in the Artifact Registry Repository,
- Storage Object Viewer (`roles/storage.objectViewer`) in the Storage Bucket.

See the [main.tf](../test/setup/template-project/main.tf) file of the test setup for an example of usage,
this example needs Cloud Build api to be enabled in the project of the `service_account_email` input.
