# Regional DLP transform BigQuery to BigQuery (Streaming) flex template

## Build the flex template

Set the following environment variables based in the resources create in the infrastructure step:

```shell
export LOCATION=<REPOSITORY-LOCATION>
export PROJECT=<YOUR-PROJECT>
export BUCKET=<YOUR-FLEX-TEMPLATE-BUCKET>
export TEMPLATE_IMAGE_TAG="$LOCATION-docker.pkg.dev/$PROJECT/flex-templates/samples/regional_bqhttps://meet.google.com/mqt-ffcx-uoc_dlp_bq_flex:latest"
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

## Using flex-template

 This flex-template supports processing the entire BigQuery table or just a query result. If you have a dataset to be entirely processed, use the `input_table` parameter. If you just want to read a piece of data of a dataset use the `query` parameter.

 For example, to process public datasets it is recommended to use the `query` parameter instead of the `input_table` parameter. But if you want to process your own datasets and all of the data in it, use `input_table` parameter.

 This flex-template only supports using one of the parameters at a time.
