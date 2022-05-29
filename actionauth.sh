#!/bin/bash
[ -z "$INPUT_APP_PEM" ] && echo "INPUT_APP_PEM not set" && exit 1
[ -z "$INPUT_APP_ID" ] && echo "INPUT_APP_ID not set" && exit 1

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
JSON=$($SCRIPT_DIR/accesstoken.sh $INPUT_APP_ID $INPUT_APP_PEM true)

echo $JSON | jq -r '.permissions'
TOKEN=$(echo -n $JSON | jq -r '.token')

printf "::add-mask::%s\n" $TOKEN
printf "::set-output name=app_token::%s\n" $TOKEN
