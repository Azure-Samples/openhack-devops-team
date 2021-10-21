#!/bin/bash

# https://github.com/gotestyourself/gotestsum
if [[ "${OSTYPE}" == "linux-gnu"* ]]; then
    os_type="linux"
elif [[ "${OSTYPE}" == "darwin"* ]]; then
    os_type="darwin"
fi

OSARCH=$(uname -m)
if [[ "${OSARCH}" == "x86_64"* ]]; then
    os_arch="amd64"
elif [[ "${OSARCH}" == "arm"* ]]; then
    os_arch="arm"
fi

gotestsum_url=$(curl -s https://api.github.com/repos/gotestyourself/gotestsum/releases/latest | jq -c -r '.assets[] | select(.name | contains("'${os_type}'") and contains("'${os_arch}'")) | .browser_download_url')
curl -sSL "${gotestsum_url}" | tar -xz gotestsum