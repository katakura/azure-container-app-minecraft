#!/bin/bash
set -eu -o pipefail

rg='rg-minecraft-java-server'
loc='japaneast'

az group create -n ${rg} -l ${loc}
az deployment group create -g ${rg} --template-file mc.bicep --parameter mc.bicepparam
