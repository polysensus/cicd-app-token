#!/bin/bash
[ -z "$INPUT_APP_PEM" ] && echo "INPUT_APP_PEM not set" && exit 1
[ -z "$INPUT_APP_ID" ] && echo "INPUT_APP_ID not set" && exit 1

export TOKEN=$(cat <<PYEND | python3
import os, time, base64
import jwt
from cryptography.hazmat.backends import default_backend

now = int(time.time())
app_id = os.environ["INPUT_APP_ID"]
payload = {
  "iat": now,
  "exp": now + (60),
  "iss": app_id
}
pem = base64.b64decode(os.environ["INPUT_APP_PEM"])
key = default_backend().load_pem_private_key(pem, None)
print(jwt.encode(payload, key, algorithm='RS256'))
PYEND
)

INSTALLATION_ID=$(curl -s -X GET \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/app/installations | jq -r .[0].id)

JSON=$(curl -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens)

echo -n $JSON | jq -r '.permissions'
TOKEN=$(echo -n $JSON | jq -r '.token')

printf "::add-mask::%s\n" $TOKEN
printf "::set-output name=app_token::%s\n" $TOKEN
