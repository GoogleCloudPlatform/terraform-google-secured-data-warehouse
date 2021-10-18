# Populate the Python artifact registry

Upload to the Python artifact registry the modules that will be used when the Python Dataflow jobs is staged.

```shell
export LOCATION=<REPOSITORY-LOCATION>
export PROJECT=<YOUR-PROJECT>

gcloud beta builds submit \
 --project=$PROJECT \
 --config ./cloudbuild.yaml . \
--substitutions="_REPOSITORY_ID=python-modules,_DEFAULT_REGION=$LOCATION"
 ```
