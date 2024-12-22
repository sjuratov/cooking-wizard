#!/bin/bash
set -e 

echo "Running preprovision hook..."

export AZURE_AUTH_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)

azd env set AZURE_AUTH_OBJECT_ID "$AZURE_AUTH_OBJECT_ID"