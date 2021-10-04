#!/bin/bash

# set -euo pipefail
IFS=$'\n\t'

usage() { echo "Usage: service_check.sh -d <dns host Url> -n <teamName> " 1>&2; exit 1; }

declare dnsUrl=""
declare teamName=""

# Initialize parameters specified from command line
while getopts ":d:n:" arg; do
    case "${arg}" in
        d)
            dnsUrl=${OPTARG}
        ;;
        n)
            teamName=${OPTARG}
        ;;
    esac
done
shift $((OPTIND-1))

#Prompt for parameters is some required parameters are missing
if [[ -z "$dnsUrl" ]]; then
    echo "Public DNS address where the API will be hosted behind."
    echo "Enter public DNS name."
    read dnsUrl
    [[ "${dnsUrl:?}" ]]
fi

if [[ -z "$teamName" ]]; then
    echo "Enter a team name to be used in app provisioning:"
    read teamName
fi

echo "Checking services for ([X] = PASSED):"
echo "Team Name:" $teamName
echo -e "DNS Url:" $dnsUrl"\n"

poi_URL=$dnsUrl"/api/healthcheck/poi"
user_URL=$dnsUrl"/api/healthcheck/user"
trips_URL=$dnsUrl"/api/healthcheck/trips"
user_java_URL=$dnsUrl"/api/healthcheck/user-java"

echo -e "Checking POI:\t"$poi_URL
echo -e "Checking USER:\t"$user_URL
echo -e "Checking TRIPS:\t"$trips_URL
echo -e "Checking USER JAVA:\t"$user_java_URL"\n"

status_code_poi=`curl -sL -w "%{http_code}\\n" "$poi_URL" -o /dev/null`

if [[ "$status_code_poi" == "200" ]]; then
    echo "poi   [X]"
else
    echo "poi   [ ]"
fi

status_code_user=`curl -sL -w "%{http_code}\\n" "$user_URL" -o /dev/null`

if [[ "$status_code_user" == "200" ]]; then
    echo "user  [X]"
else
    echo "user  [ ]"
fi

status_code_trips=`curl -sL -w "%{http_code}\\n" "$trips_URL" -o /dev/null`

if [[ "$status_code_trips" == "200" ]]; then
    echo "trips [X]"
else
    echo "trips [ ]"
fi

status_code_user_java=`curl -sL -w "%{http_code}\\n" "$user_java_URL" -o /dev/null`

if [[ "$status_code_user_java" == "200" ]]; then
    echo "user-java [X]"
else
    echo "user-java [ ]"
fi

if [[ "$status_code_poi" == "200" ]] && [[ "$status_code_user" == "200" ]] && [[ "$status_code_trips" == "200" ]] && [[ "$status_code_user_java" == "200" ]]; then
    echo "All checks passed"
fi