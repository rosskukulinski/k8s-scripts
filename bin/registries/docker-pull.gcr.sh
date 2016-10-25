#!/bin/bash -e

if [ -z "$GCP_PROJECT" || -z "$GCP_CLUSTER" || -z "$GCP_ZONE" ]; then
  echo "Missing GCP project, cluster, or zone!  Aborting"
  exit 1
fi

if ! hash pyopenssl 2>/dev/null; then
  pip install pyopenssl
fi

if [ ! -d ~/google-cloud-sdk ]; then
  curl https://sdk.cloud.google.com | bash;
  ~/google-cloud-sdk/bin/gcloud components update #--version 119.0.0
fi

# TODO: Is this necessary if we have the kube config already set up for
# cluster connection?

KEYFILE=${HOME}/gcloud-service-key.json
echo $GCLOUD_SERVICE_KEY | base64 --decode > "${KEYFILE}"
~/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file "${KEYFILE}"

~/google-cloud-sdk/bin/gcloud config set project "${GCP_PROJECT}"
~/google-cloud-sdk/bin/gcloud config set container/cluster "${GCP_CLUSTER}"
~/google-cloud-sdk/bin/gcloud config set compute/zone "${GCP_ZONE}"

# Authorize the docker client to work with GCR
gcloud docker --authorize-only
