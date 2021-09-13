# Flex Templates Samples

This is a Dataflow [Flex Template](https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates) sample that can be used to validate the flow of data in the Data Warehouse Secure Blueprint.

In this sample folder we have

- A [terraform infrastructure script](./infrastructure) to create the Artifact Registry Repository and Google Cloud Storage Bucket to store the flex template.
- The [source code](./java/regional_dlp_de_identification/src/main/java/org/apache/beam/samples/DLPTextToBigQueryStreaming.java) for a DLP de-identification Flex template that:
  - Reads records from a CSV file uploaded to a Storage Bucket,
  - Apply regional DLP de-identification transformation to the records,
  - Write the de-identified records to BigQuery.
- A [Cloud build file](./java/regional_dlp_de_identification/cloudbuild.yaml) to build the template.

This template is based in the public [DLP Text to BigQuery (Streaming)](https://github.com/GoogleCloudPlatform/DataflowTemplates/blob/master/src/main/java/com/google/cloud/teleport/templates/DLPTextToBigQueryStreaming.java) template from the [Google Cloud Dataflow Template Pipelines](https://github.com/GoogleCloudPlatform/DataflowTemplates).

This template has been adjusted to allow regional DLP API calls and to request a explicit project ID for the  BigQuery Dataset instead of using the DLP Project ID.

The Data Warehouse Secure Blueprint main module [creates](../README.md#outputs) a user-managed Dataflow [controller service account](https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_worker_service_account).
This service account is used to stage and run the Dataflow job.

To be able to deploy this Flex template you need to grant to the Dataflow controller service account the following roles in the resources create in the infrastructure script:

- Artifact Registry Reader (`roles/artifactregistry.reader`) in the Artifact Registry Repository,
- Storage Object Viewer (`roles/storage.objectViewer`) in the Storage Bucket.
