#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

usage() { echo "Usage: send_msg -e <recipientEmail> -c <chatConnectionString> -q <chatMessageQueue> -m <message>" 1>&2; exit 1; }

declare recipientEmail=""
declare chatConnectionString=""
declare chatMessageQueue=""
declare message=""

# Initialize parameters specified from command line
while getopts ":e:c:q:m:" arg; do
    case "${arg}" in
        e)
            recipientEmail=${OPTARG}
        ;;
        c)
            chatConnectionString=${OPTARG}
        ;;
        q)
            chatMessageQueue=${OPTARG}
        ;;
        m)
            message=${OPTARG}
        ;;
    esac
done
shift $((OPTIND-1))

if [[ -z "$recipientEmail" ]]; then
    echo "recipientEmail was not set properly"
    read recipientEmail
fi

if [[ -z "$chatConnectionString" ]]; then
    echo "chatConnectionString was not set properly"
    read chatConnectionString
fi

if [[ -z "$chatMessageQueue" ]]; then
    echo "chatMessageQueue was not set properly"
    read chatMessageQueue
fi

if [[ -z "$message" ]]; then
    echo "message was not set properly"
    read message
fi

cd /home/azureuser/openhack-devops-proctor/provision-team/svcbusclient

# Restore the ServiceBus Package
dotnet add package Microsoft.Azure.ServiceBus --version 3.1.0

# build the servicebus client app
dotnet build

# send the message to servicebus
dotnet run $chatConnectionString $chatMessageQueue $recipientEmail $message
