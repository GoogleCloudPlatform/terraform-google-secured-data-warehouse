# Regional DLP de-identification Text to BigQuery (Streaming) flex template

## Build the flex template with Cloud Build

Set the following environment variables based in the resources create in the infrastructure step:

```shell
export LOCATION=<REPOSITORY-LOCATION>
export PROJECT=<YOUR-PROJECT>
export BUCKET=<YOUR-FLEX-TEMPLATE-BUCKET>
export FLEX_REPO_URL=$LOCATION-docker.pkg.dev/$PROJECT/flex-templates
```

```shell
# build the flex template

gcloud beta builds submit \
 --project=$PROJECT \
 --config ./cloudbuild.yaml . \
 --substitutions="_BUCKET=$BUCKET,_PROJECT=$PROJECT,_FLEX_REPO_URL=$FLEX_REPO_URL"
 ```

**Note:** It is possible to migrate the maven image used to a Artifact Registry in your organization.
Follow the instructions in [Migrating containers from a third-party registry](https://cloud.google.com/artifact-registry/docs/docker/migrate-external-containers)
to migrate the `maven:3.8.2-jdk-11` image.

After migrating the image, update the cloudbuild.yaml file to used the image in the new repository, for example, for the artifact registry repository with name `migrated-images` in the `us-central1` location at project `your-project` use:

```diff
steps:
- - name: 'maven:3.8.2-jdk-11'
+ - name: 'us-central1-docker.pkg.dev/your-project/migrated-images/maven:3.8.2-jdk-11'
  entrypoint: 'mvn'
```

## Build the flex template manually

Follow the instructions in [Using Flex Templates:Setting up your development environment](https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates#setting_up_your_development_environment) to configure your environment to build the images.

After configuring your environment set the following environment variables based in the resources create in the infrastructure step:

```shell
export LOCATION=<REPOSITORY-LOCATION>
export PROJECT=<YOUR-PROJECT>
export BUCKET=<YOUR-FLEX-TEMPLATE-BUCKET>
```

Run Maven to create the uber-jar file:

```shell
 mvn clean package
```

Build the Flex Image:

```shell
export TEMPLATE_IMAGE="$LOCATION-docker.pkg.dev/$PROJECT/flex-templates/samples/regional-txt-dlp-bq-streaming:latest"

export TEMPLATE_PATH="gs://$BUCKET/flex-template-samples/regional-txt-dlp-bq-streaming.json"

gcloud dataflow flex-template build $TEMPLATE_PATH \
  --image-gcr-path "$TEMPLATE_IMAGE" \
  --sdk-language "JAVA" \
  --project=$PROJECT \
  --flex-template-base-image JAVA11 \
  --metadata-file "./metadata.json" \
  --jar "./target/regional-txt-dlp-bq-streaming-1.0.jar" \
  --env FLEX_TEMPLATE_JAVA_MAIN_CLASS="org.apache.beam.samples.DLPTextToBigQueryStreaming"
```
