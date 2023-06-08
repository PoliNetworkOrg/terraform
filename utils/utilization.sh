#!/bin/bash

PODS=$(kubectl get pods --all-namespaces -o json)

echo "${PODS}" | jq -r '.items[] | select(.spec.containers[].resources.requests.memory) | "\(.metadata.namespace) \(.metadata.name) \(.spec.containers[].resources.requests.memory)"' | while read -r ns pod mem ; do
  echo "Checking pod ${ns}/${pod}"
  
  # check if memory request is not in Mi or if it's not set
  if [[ ! ${mem} =~ [0-9]+Mi ]]; then
    echo "Pod ${ns}/${pod} has no memory request set or it's not in Mi"
    continue
  fi
  
  MEM_REQ=$(echo "${mem}" | awk -F"M" '{print $1}')
  echo "Memory requested for pod ${ns}/${pod}: ${MEM_REQ}Mi"

  # Check if 'kubectl top pod' command is working properly
  if ! kubectl top pod "${pod}" --namespace "${ns}" > /dev/null 2>&1; then
    echo "Error getting the top pod ${ns}/${pod}. Please ensure the 'kubectl top' command works properly."
    continue
  fi

  MEM_USE=$(kubectl top pod "${pod}" --namespace "${ns}" | awk 'NR>1{print $3}' | awk -F"Mi" '{print $1}')
  
  if [[ $(echo "${MEM_USE} > ${MEM_REQ}" | bc) -eq 1 ]]; then
    echo "Pod ${ns}/${pod} is using more memory than requested"
  fi
done
