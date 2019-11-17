#!/bin/bash 

set -o errexit

OPTIONS=hi:u:
LONGOPTS=help,client-id:,callback-url:

client_id=""
callback_url=""

! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -h|--help)
            echo "Usage: ${0} --client-id CLIENT_ID --callback-url CALLBACK_URL"
            echo
            echo 
            echo "    --client-id CLIENT_ID:      register the client with CLIENT_ID"
            echo "    --callback-url CALLBACK_URL register CALLBACK_URL for the client"
            echo
            echo "The client will be registered with a random secret which is written"
            echo "to stdout on successful exit."
            exit 0
            shift
            ;;
        -i|--client-id)
            client_id="$2"
            shift 2
            ;;
        -u|--callback-url)
            callback_url="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

if [ -z ${client_id} ] || [ -z ${callback_url} ] ; then
    echo "Error: both --client-id and --callback-url must be specified."
    exit 1
fi

client_secret=$(export LC_CTYPE=C; cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

docker run --rm -it \
  --network dcc_default \
  oryd/hydra:v1.0.8 \
  clients create \
    --endpoint http://oauth-server:4445 \
    --callbacks ${callback_url} \
    --id ${client_id} \
    --secret ${client_secret} \
    --grant-types authorization_code,refresh_token \
    --response-types token,code \
    --scope openid,offline \
    --token-endpoint-auth-method client_secret_basic \
    --fake-tls-termination

echo "Registered OAuth2 client successfully"
echo "Client ID: ${client_id}"
echo "Client Secret: ${client_secret}"
echo "Callback URL: ${callback_url}"

exit 0

