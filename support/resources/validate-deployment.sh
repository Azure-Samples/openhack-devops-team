#!/bin/bash

# This script verifies the successfull deployment of the resources needed for the DevOps OpenHack.
# You need to provide the CSV file with all the credentials of the Azure subscriptions from the classroom management portal and a private / public SSH keypair that will be used to access the provisioning VMs
# The error log file is where will be logged the informations regarding the failed deployments. If not provided, it defaults to error.log. 
#
# EXAMPLE
# ./validate-deployment.sh ./credentials.csv
# ./validate-deployment.sh ./credentials.csv --force

OLD_IFS=$IFS
CREDENTIALS_FILE_PATH=$1
FORCE_OVERWRITE=$2
RESULTS_FILE_PATH="./classcheckresults.csv"
IFS=','

[ ! -f $CREDENTIALS_FILE_PATH ] && { echo "$CREDENTIALS_FILE_PATH file not found"; exit 99; }

[ -f $RESULTS_FILE_PATH ] && {
  [ -z $FORCE_OVERWRITE ] && {
    echo "Found previous output ($RESULTS_FILE_PATH). Would you like to delete it?"
    select yn in "Yes" "No"; do
      case $yn in
          Yes ) rm $RESULTS_FILE_PATH; break;;
          No ) break;;
      esac
    done
  }
  [ ! -z $FORCE_OVERWRITE ] && {
    rm $RESULTS_FILE_PATH
  }
}

echo "Storing validation results at $RESULTS_FILE_PATH"

echo '"SiteFound","POIFound","TripsFound","UserFound","UserJavaFound","TripViewerUrl","AzureUsername","AzurePassword","SubscriptionId","TenantURL"' >> $RESULTS_FILE_PATH

while read PortalUsername PortalPassword AzureSubscriptionId AzureDisplayName AzureUsername AzurePassword
do
  if [[ $PortalUsername = *Portal* ]]
  then
    echo "This is the header, skipping..."
  elif [[ $AzureUserName = *hacker* ]]
  then
    echo "This is a hacker user, skipping..."
  else
    echo "PortalUsername $PortalUsername"
    echo "PortalPassword $PortalPassword"
    echo "AzureSubscriptionId $AzureSubscriptionId"
    echo "AzureDisplayName $AzureDisplayName"
    echo "AzureUsername $AzureUsername"
    echo "AzurePassword $AzurePassword"

    az login -u $AzureUsername -p $AzurePassword --output none

    TENANT_URL="https://portal.azure.com/"
    TENANT_URL+=`echo "$AzureUsername" | awk -F"@" '{print $2}'`

    RESOURCE_GROUP_NAME=`az group list --query "[?starts_with(name,'openhack')]|[0]" | jq -r '.name'`

    TEAM_NAME=${RESOURCE_GROUP_NAME%??}

    ROW_TO_APPEND="\"True\","

    FQDN_POI=`az webapp show --resource-group "$RESOURCE_GROUP_NAME" --name "${TEAM_NAME}poi" --query "[].{hostName:defaultHostName}|[0]" --output tsv`
    FQDN_TRIPS=`az webapp list --resource-group "$RESOURCE_GROUP_NAME" --name "${TEAM_NAME}trips" --query "[].{hostName:defaultHostName}|[0]" --output tsv`
    FQDN_USER_JAVA=`az webapp list --resource-group "$RESOURCE_GROUP_NAME" --name "${TEAM_NAME}userjava" --query "[].{hostName:defaultHostName}|[0]" --output tsv`
    FQDN_USER_PROFILE=`az webapp list --resource-group "$RESOURCE_GROUP_NAME" --name "${TEAM_NAME}userprofile" --query "[].{hostName:defaultHostName}|[0]" --output tsv`

    FQDN_TRIP_VIEWER=`az webapp list --resource-group "$RESOURCE_GROUP_NAME" --name "${TEAM_NAME}tripviewer" --query "[].{hostName:defaultHostName}|[0]" --output tsv`

    STATUS=$(curl --write-out %{http_code} --silent --output /dev/null $FQDN_POI/api/healthcheck/poi)
    if [ $STATUS -eq 200 ]
    then
      ROW_TO_APPEND+="\"True\","
    else
      ROW_TO_APPEND+="\"False\","
    fi

    STATUS=$(curl --write-out %{http_code} --silent --output /dev/null $FQDN_TRIPS/api/healthcheck/trips)
    if [ $STATUS -eq 200 ]
    then
      ROW_TO_APPEND+="\"True\","
    else
      ROW_TO_APPEND+="\"False\","
    fi

    STATUS=$(curl --write-out %{http_code} --silent --output /dev/null $FQDN_USER_PROFILE/api/healthcheck/user)
    if [ $STATUS -eq 200 ]
    then
      ROW_TO_APPEND+="\"True\","
    else
      ROW_TO_APPEND+="\"False\","
    fi

    STATUS=$(curl --write-out %{http_code} --silent --output /dev/null $FQDN_USER_JAVA/api/healthcheck/user-java)
    if [ $STATUS -eq 200 ]
    then
      ROW_TO_APPEND+="\"True\","
    else
      ROW_TO_APPEND+="\"False\","
    fi

    ROW_TO_APPEND+="\"$FQDN_TRIP_VIEWER\",\"$PortalUsername\",\"$PortalPassword\",\"$AzureSubscriptionId\",\"$TENANT_URL\""

    echo $ROW_TO_APPEND >> $RESULTS_FILE_PATH

    echo "Done for $AzureUsername"
  fi

done < $CREDENTIALS_FILE_PATH
IFS=$OLD_IFS
