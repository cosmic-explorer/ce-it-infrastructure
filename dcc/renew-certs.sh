#!/bin/bash

set -x

export SHIB_HEADER_SECRET=$(cat /run/secrets/shib_header_secret)
export REST_AUTHORIZED_EPPN=$(cat /run/secrets/rest_authorized_eppn)

httpd -k graceful

exit 0
