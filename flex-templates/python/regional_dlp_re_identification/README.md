# Regional DLP de-identification Pub/Sub to BigQuery (Streaming) flex template

## Build the flex template

Set the following environment variables based in the resources create in the infrastructure step:

```shell
export LOCATION=<REPOSITORY-LOCATION>
export PROJECT=<YOUR-PROJECT>
export BUCKET=<YOUR-FLEX-TEMPLATE-BUCKET>
export TEMPLATE_IMAGE_TAG="$LOCATION-docker.pkg.dev/$PROJECT/flex-templates/samples/regional_bq_dlp_bq_flex:latest"
export TEMPLATE_GS_PATH="gs://$BUCKET/flex-template-samples/regional_bq_dlp_bq_flex.json"
export PIP_INDEX_URL="https://$LOCATION-python.pkg.dev/$PROJECT/python-modules/simple/"
```

### Create the template with Cloud Build

```shell
# build the flex template

gcloud beta builds submit \
 --project=$PROJECT \
 --config ./cloudbuild.yaml . \
 --substitutions="_PROJECT=$PROJECT,_FLEX_TEMPLATE_IMAGE_TAG=$TEMPLATE_IMAGE_TAG,_TEMPLATE_GS_PATH=$TEMPLATE_GS_PATH,_PIP_INDEX_URL=$PIP_INDEX_URL"
 ```

### Manually Create the template

Build the Flex Image:

```shell

docker build \
--tag="$TEMPLATE_IMAGE_TAG"
--build-arg=ARG_PIP_INDEX_URL="$PIP_INDEX_URL" \
.

gcloud dataflow flex-template build "$TEMPLATE_GS_PATH" \
  --image "$TEMPLATE_IMAGE_TAG" \
  --sdk-language "PYTHON" \
  --project=$PROJECT \
  --metadata-file "./metadata.json"
```
