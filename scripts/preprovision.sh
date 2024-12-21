#!/bin/bash
set -e 

echo "Running preprovision hook..."

#azd env set AZURE_AUTH_OBJECT_ID "$(az ad signed-in-user show --query id -o tsv)"

export AZURE_AUTH_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)

echo "Object ID of current user : $AZURE_AUTH_OBJECT_ID"