#!/bin/bash

declare -i duration=5
declare endpoint
declare key
declare value

usage() {
    cat <<END
    healthcheck.sh endpoint key value

    Report the health status of the endpoint. Exit 0 then OK.
END
}

if [[ $1 ]]; then
    endpoint=$1
else
    echo "Please specify the endpoint to scan"
    usage
    exit 1
fi

if [[ $2 ]]; then
    key=$2
else
    echo "Please specify the key that has to be queried"
    usage
    exit 1
fi

if [[ $3 ]]; then
    value=$3
else
    echo "Please specify the value that has to be expected"
    usage
    exit 1
fi

query() {
    local endpoint=$1
    local key=$2

    result=$(curl --max-time 5 --silent --location "${endpoint}")

    if jq -e . >/dev/null 2>&1 <<<"${result}"; then
        echo "${result}" | jq -c -r '.'"${key}"''
    fi
}

while [[ true ]]; do
    result=$(query "${endpoint}" "${key}")

    if [[ "${result}" == "${value}" ]]; then
        echo true
        exit 0
    fi
    sleep ${duration}
done
