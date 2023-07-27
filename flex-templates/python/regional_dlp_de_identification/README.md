# Regional DLP de-identification Pub/Sub to BigQuery (Streaming) flex template

This template is a combination of the public [Streaming Wordcount](https://github.com/apache/beam/blob/master/sdks/python/apache_beam/examples/streaming_wordcount.py) example and the [Apache Beam Cloud CLP Transform](https://github.com/apache/beam/blob/master/sdks/python/apache_beam/ml/gcp/cloud_dlp.py)

The Apache Beam Cloud CLP Transform has been changed to allow regional structured DLP API calls and simplified with the exclusion of the DLP inspection code.

## Build the flex template

Set the following environment variables based in the resources create in the infrastructure step:

```shell
export LOCATION="us-west1"
export PROJECT="pjr-seed-serverless-test"
export BUCKET="pjr-seed-serverless-test_cloudbuild"
export TEMPLATE_IMAGE_TAG="$LOCATION-docker.pkg.dev/$PROJECT/flex-templates/samples/regional-python-dlp-flex:latest"
export TEMPLATE_GS_PATH="gs://$BUCKET/flex-template-samples/regional-python-dlp-flex.json"
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
