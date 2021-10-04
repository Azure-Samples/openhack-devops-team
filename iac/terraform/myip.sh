#!/bin/bash
set -e
MYIP="$(dig +short myip.opendns.com @resolver1.opendns.com -4)"
echo $(jq -n --arg MYIP "$MYIP" '{"my_ip":$MYIP}')