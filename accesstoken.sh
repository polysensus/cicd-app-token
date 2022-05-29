#!/bin/bash

# Minimalist script for authenticating as a github app

# See
# - https://dev.to/dtinth/authenticating-as-a-github-app-in-a-github-actions-workflow-27co
# - https://docs.github.com/en/developers/apps/building-github-apps
#
# APP_ID APP_PEM are required as $1 and $2 resepectively
#
# $1 APP_ID  - is the github app id
# $2 APP_PEM - is it the app private RSA key base64 encoded as a single line
#              string (cat pem | base64 -w 0)
#
# $3         - pass 'true' to report the full token response (including permissions)

[ "$#" -lt 2 ] && echo "missing positional args: APP_ID APP_PEM (have $#)" && exit 1
export APP_ID=$1
export APP_PEM=$2

SHOW_PERMS=false
[ "$#" -gt 2 ] && SHOW_PERMS=$3

export TOKEN=$(cat <<PYEND | python3
import os, time, base64
import jwt
from cryptography.hazmat.backends import default_backend

now = int(time.time())
app_id = os.environ["APP_ID"]
payload = {
  "iat": now,
  "exp": now + (60),
  "iss": app_id
}
pem = base64.b64decode(os.environ["APP_PEM"])
key = default_backend().load_pem_private_key(pem, None)
token = jwt.encode(payload, key, algorithm='RS256')

# deal bytes or str depending on python version
try:
    token = token.decode()
except (UnicodeDecodeError, AttributeError):
    pass
print(token)
PYEND
)

INSTALLATION_ID=$(curl -s -X GET \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/app/installations | jq -r '.[0].id')

JSON=$(curl -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens)

$SHOW_PERMS && echo -n $JSON && exit 0
echo -n $JSON | jq -r '.token'
