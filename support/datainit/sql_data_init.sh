#!/bin/bash

# set -euo pipefail
IFS=$'\n\t'

usage() { echo "Usage: sql_data_init.sh -s <SQL Server FQDN> -u <sql username> -p <sql password> -d <databaseName> " 1>&2; exit 1; }

declare sqlServerFQDN=""
declare sqlServerUsername=""
declare sqlPassword=""
declare sqlDBName=""

# Initialize parameters specified from command line
while getopts ":s:u:p:d:" arg; do
    case "${arg}" in
        s)
            sqlServerFQDN=${OPTARG}
        ;;
        u)
            sqlServerUsername=${OPTARG}
        ;;
        p)
            sqlPassword=${OPTARG}
        ;;
        d)
            sqlDBName=${OPTARG}
        ;;
    esac
done
shift $((OPTIND-1))

if [[ -z "$sqlServerFQDN" ]]; then
    echo "Enter FQDN to SQL Server:"
    read sqlServerFQDN
    [[ "${sqlServerFQDN:?}" ]]
fi

if [[ -z "$sqlServerUsername" ]]; then
    echo "Enter the SQL Server User name:"
    read sqlServerUsername
    [[ "${sqlServerUsername:?}" ]]
fi

if [[ -z "$sqlPassword" ]]; then
    echo "Enter the sql server password:"
    read sqlPassword
    [[ "${sqlPassword:?}" ]]
fi

if [[ -z "$sqlDBName" ]]; then
    echo "Enter the name of the SQL Server DB that was provisioned in shared infrastructure:"
    read sqlDBName
fi

echo "Importing Devices"
bcp Devices in ./data_load/Devices_export.txt -S $sqlServerFQDN -U $sqlServerUsername -P $sqlPassword -d $sqlDBName -c -t ','

echo "Importing factMLOutputData"
bcp factMLOutputData in ./data_load/factMLOutputData_export.txt -S $sqlServerFQDN -U $sqlServerUsername -P $sqlPassword -d $sqlDBName -c -t ','

echo "Importing IOTHubDatas"
bcp IOTHubDatas in ./data_load/IOTHubDatas_export.txt -S $sqlServerFQDN -U $sqlServerUsername -P $sqlPassword -d $sqlDBName -c -t ','

echo "Importing POIs"
bcp POIs in ./data_load/POIs_export.txt -S $sqlServerFQDN -U $sqlServerUsername -P $sqlPassword -d $sqlDBName -c -t ','

echo "Importing TripPoints"
bcp TripPoints in ./data_load/TripPoints_export.txt -S $sqlServerFQDN -U $sqlServerUsername -P $sqlPassword -d $sqlDBName -c -t ','

echo "Importing Trips"
bcp Trips in ./data_load/Trips_export.txt -S $sqlServerFQDN -U $sqlServerUsername -P $sqlPassword -d $sqlDBName -c -t ','

echo "Importing UserProfiles"
bcp UserProfiles in ./data_load/UserProfiles_export.txt -S $sqlServerFQDN -U $sqlServerUsername -P $sqlPassword -d $sqlDBName -c -t ','

echo "Importing POISource"
bcp POISource in ./data_load/POISource_export.txt -S $sqlServerFQDN -U $sqlServerUsername -P $sqlPassword -d $sqlDBName -c -t ','

echo "Importing TripPointSource"
bcp TripPointSource in ./data_load/TripPointSource_export.txt -S $sqlServerFQDN -U $sqlServerUsername -P $sqlPassword -d $sqlDBName -c -t ','
