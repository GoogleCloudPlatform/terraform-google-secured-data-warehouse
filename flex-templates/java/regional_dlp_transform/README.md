# Regional DLP Transformation BigQuery to BigQuery flex template

## Build the flex template with Cloud Build

The java dataflow is inspired by the work captured by a DLP solution.  Learn more at [Migrate Sensitive Data in BigQuery Using Dataflow & Cloud DLP](https://github.com/GoogleCloudPlatform/dlp-dataflow-deidentification)

Set the following environment variables based in the resources create in the infrastructure step:

```shell
export LOCATION=<REPOSITORY-LOCATION>
export PROJECT=<YOUR-PROJECT>
export BUCKET=<YOUR-FLEX-TEMPLATE-BUCKET>
export TEMPLATE_IMAGE_TAG="$LOCATION-docker.pkg.dev/$PROJECT/flex-templates/samples/regional-bq-dlp-bq-streaming:latest"
export TEMPLATE_GS_PATH="gs://$BUCKET/flex-template-samples/regional-bq-dlp-bq-streaming.json"
```

```shell
# build the flex template

gcloud beta builds submit \
 --project=$PROJECT \
 --config ./cloudbuild.yaml . \
 --substitutions="_PROJECT=$PROJECT,_FLEX_TEMPLATE_IMAGE_TAG=$TEMPLATE_IMAGE_TAG,_TEMPLATE_GS_PATH=$TEMPLATE_GS_PATH"
 ```

**Note:** It is possible to migrate the maven image used to a Artifact Registry in your organization.
Follow the instructions in [Migrating containers from a third-party registry](https://cloud.google.com/artifact-registry/docs/docker/migrate-external-containers)
to migrate the `maven:3.8.2-jdk-11` image.

After migrating the image, update the cloudbuild.yaml file to used the image in the new repository, for example, for the artifact registry repository with name `migrated-images` in the `us-east4` location at project `your-project` use:

```diff
steps:
- - name: 'maven:3.8.2-jdk-11'
+ - name: 'us-east4-docker.pkg.dev/your-project/migrated-images/maven:3.8.2-jdk-11'
  entrypoint: 'mvn'
```

## Run the flex template manually

1. Follow the instructions in [Using Flex Templates:Setting up your development environment](https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates#setting_up_your_development_environment) to configure your environment to build the images.
2. Build the flex template
3. make sure you have input BigQuery table available with correct data (and corresponding DLP template)
4. apply the [example/standalone](../../../examples/standalone/README.md)
5. run the dataflow job

```shell
export LOCATION=<REPOSITORY-LOCATION>
export PROJECT=<YOUR-PROJECT>
export TEMPLATE_PATH=<YOUR_GCS_PATH> # e.g "gs://BUCKET/flex-template-samples/regional-bq-dlp-bq-streaming.json"
```

Run the Flex Image:

```shell
gcloud dataflow flex-template run "regional-bq-dlp-bq-`date +%Y%m%d-%H%M%S`" \
    --template-file-gcs-location "$TEMPLATE_PATH" \
    --parameters inputBigQueryTable="PROJECT:DATASET.TABLE" \
    --parameters outputBigQueryTable="PROJECT:DATASET.TABLE" \
    --parameters deidentifyTemplateName="FULL_DEIDENTIFY_TEMPLATE_NAME" \
    --parameters dlpProjectId="DLP_PROJECT_ID" \
    --parameters dlpLocation="DLP_LOCATION" \
    --parameters confidentialDataProjectId="CONFIDENTIAL_DATA_PROJECT_ID" \
    --parameters dlpTransform="DLP_TRANSFORMATION_TYPE" \
    --parameters batchSize="BATCH_SIZE" \
    --parameters bqSchema="FIELD_1:STRING,FIELD_2:STRING,..." \
    --project=${PROJECT} \
    --service-account-email="DATAFLOW_SERVICE_ACCOUNT" \
    --subnetwork="SUBNETWORK" \
    --region="${LOCATION}" \
    --disable-public-ips \
    --enable-streaming-engine
```
