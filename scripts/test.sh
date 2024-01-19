#!/bin/bash

# Define variables
IMAGE_NAME=$(echo $2 | tr '[:upper:]' '[:lower:]')
TAG_NAME=$1
MODULE_NAMES=('Az.Accounts' 'Microsoft.Graph.Authentication' 'Microsoft.Graph.Beta.Users' 'ExchangeOnlineManagement')
COMMANDS=('Connect-AzAccount' 'Connect-MgGraph' 'Get-MgBetaUser' 'Connect-ExchangeOnline')

# Run the Docker container and execute the command to check for pwsh
docker run --rm $IMAGE_NAME:$TAG_NAME pwsh -c '$PSVersionTable.PSVersion'
[ $? -ne 0 ] && echo "Failed to run pwsh" >&2 && exit 1

# Run the Docker container and execute the commands to check for each module
for i in "${!MODULE_NAMES[@]}"; do
  docker run --rm $IMAGE_NAME:$TAG_NAME pwsh -c "try { Import-Module ${MODULE_NAMES[i]} -ErrorAction Stop; Write-Output ('Successfully imported module {0}' -f '${MODULE_NAMES[i]}') } catch { Write-Error ('Failed importing module {0}: {1}' -f '${MODULE_NAMES[i]}', \$_); exit 1 } if (Get-Command ${COMMANDS[i]}) { Write-Output ('Command {0} found' -f '${COMMANDS[i]}') } else { Write-Error ('Command {0} not found' -f '${COMMANDS[i]}'); exit 1 }"
done
[ $? -ne 0 ] && echo "Failed to validate PowerShell modules" >&2 && exit 1

exit 0
