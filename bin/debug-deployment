#!/bin/bash

if [ -z "$1" ]
then
  echo "ERROR: No deployment specified"
  exit 1
fi

DEPLOY=${1}
NAMESPACE=${2:=default}

printf "\n\nOk - Let's figure out why this deployment might have failed"

printf "\n\n------------------------------\n\n"

printf "> kubectl describe deployment ${DEPLOY} --namespace=${NAMESPACE}\n\n"
kubectl describe deployment ${DEPLOY} --namespace=${NAMESPACE}

printf "\n\n------------------------------\n\n"

CURRENT_GEN=$(kubectl get deployment ${DEPLOY} --namespace=${NAMESPACE} -o jsonpath='{.metadata.generation}')
OBS_GEN=$(kubectl get deployment ${DEPLOY} --namespace=${NAMESPACE} -o jsonpath='{.status.observedGeneration}')
REPLICAS=$(kubectl get deployment ${DEPLOY} --namespace=${NAMESPACE} -o jsonpath='{.status.replicas}')
UPDATED_REPLICAS=$(kubectl get deployment ${DEPLOY} --namespace=${NAMESPACE} -o jsonpath='{.status.updatedReplicas}')
AVAILABLE_REPLICAS=$(kubectl get deployment ${DEPLOY} --namespace=${NAMESPACE} -o jsonpath='{.status.availableReplicas}')

if [ "$AVAILABLE_REPLICAS" == "$REPLICAS" ] && \
   [ "$UPDATED_REPLICAS" == "$REPLICAS" ] ; then

  printf "Available Replicas (${AVAILABLE_REPLICAS}) equals Current Replicas (${REPLICAS}) \n"
  printf "Updated Replicas (${UPDATED_REPLICAS}) equals Current Replicas (${REPLICAS}). \n"
  printf "Are you sure the deploy failed?\n\n"
  exit 0
fi

if [ "$AVAILABLE_REPLICAS" != "$REPLICAS" ] ; then
  printf "Available Replicas (${AVAILABLE_REPLICAS}) does not equal Current Replicas (${REPLICAS}) \n"
fi

if [ "$UPDATED_REPLICAS" != "$REPLICAS" ] ; then
  printf "Updated Replicas (${UPDATED_REPLICAS}) does not equal Current Replicas (${REPLICAS}) \n"
fi

printf "\n\n------------------------------\n\n"

NEW_RS=$(kubectl describe deploy ${DEPLOY} --namespace=${NAMESPACE} | grep "NewReplicaSet" | awk '{print $2}')
POD_HASH=$(kubectl get rs ${NEW_RS} --namespace=${NAMESPACE} -o jsonpath='{.metadata.labels.pod-template-hash}')

printf "Pods for this deployment:\n\n"
printf "> kubectl get pods  --namespace=${NAMESPACE} -l pod-template-hash=${POD_HASH}\n\n"
kubectl get pods --namespace=${NAMESPACE} -l pod-template-hash=${POD_HASH}

printf "\n\n------------------------------\n\n"

printf "Detailed pods for this deployment:\n\n"

printf "> kubectl describe pods  --namespace=${NAMESPACE} -l pod-template-hash=${POD_HASH}\n\n"
kubectl describe pods --namespace=${NAMESPACE} -l pod-template-hash=${POD_HASH}

printf "\n\n------------------------------\n\n"
printf "Containers that are currently 'waiting':\n\n"
printf "> kubectl get pods --namespace=${NAMESPACE} -l pod-template-hash=${POD_HASH} -o jsonpath='...'\n"
kubectl get pods --namespace=${NAMESPACE} -l pod-template-hash=${POD_HASH} -o jsonpath='{"\n"}{range .items[*]}{@.metadata.name}:{"\n"}{range @.status.conditions[*]}{"\t"}{@.lastTransitionTime}: {@.type}={@.status}{"\n"}{end}{"\n"}{"\tWaiting Containers\n"}{range @.status.containerStatuses[?(@.state.waiting)]}{"\t\tName: "}{@.name}{"\n\t\tImage: "}{@.image}{"\n\t\tState: Waiting"}{"\n\t\tMessage: "}{@.state.waiting.message}{"\n\t\tReason: "}{@.state.waiting.reason}{end}{"\n"}{end}'

printf "\n\n------------------------------\n\n"

printf "Pods with Terminated state\n\n"

printf "> kubectl get pods --namespace=${NAMESPACE} -l pod-template-hash=${POD_HASH} -o jsonpath='...'\n"
kubectl get pods --namespace=${NAMESPACE} -l pod-template-hash=${POD_HASH} -o jsonpath='{"\n"}{range .items[*]}{"\n"}{@.metadata.name}:{"\n"}{"\n\tTerminated Containers\n"}{range @.status.containerStatuses[?(@.lastState.terminated)]}{"\t\tName: "}{@.name}{"\n\t\tImage: "}{@.image}{"\n\t\texitCode: "}{@.lastState.terminated.exitCode}{"\n\t\tReason: "}{@.lastState.terminated.reason}{"\n"}{end}{"\n"}{end}'

printf "\n\n------------------------------\n\n"

printf "Trying to get previous logs from each Terminated pod\n\n"

kubectl get pods --namespace=${NAMESPACE} -l pod-template-hash=${POD_HASH} --no-headers | awk '{print $1}' | xargs -I pod sh -c "printf \"pod\n\n\"; kubectl --namespace=${NAMESPACE} logs --previous --tail=100 --timestamps pod; printf \"\n\n\""
