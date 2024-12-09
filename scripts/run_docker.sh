#!/usr/bin/env bash

docker build -t gitlab-migrator  . -f dockerfile.migration --no-cache

set -o pipefail

client_id="$1" # Client ID as first argument

pem=$( cat $2 ) # file path of the private key as second argument

MIRROR_REPOS="${5:-true}"

now=$(date +%s)
iat=$((${now} - 60)) # Issues 60 seconds in the past
exp=$((${now} + 600)) # Expires 10 minutes in the future

b64enc() { openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n'; }

header_json='{
    "typ":"JWT",
    "alg":"RS256"
}'
# Header encode
header=$( echo -n "${header_json}" | b64enc )

payload_json="{
    \"iat\":${iat},
    \"exp\":${exp},
    \"iss\":\"${client_id}\"
}"
# Payload encode
payload=$( echo -n "${payload_json}" | b64enc )

# Signature
header_payload="${header}"."${payload}"
signature=$(
    openssl dgst -sha256 -sign <(echo -n "${pem}") \
    <(echo -n "${header_payload}") | b64enc
)

# Create JWT
JWT="${header_payload}"."${signature}"

export TOKEN=$(curl -s -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $JWT"  \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/app/installations/57151715/access_tokens | jq -r '.token')

docker run -e GITHUB_PAT="$TOKEN" \
           -e GITLAB_PAT="$3" \
           -e REPOS_FILENAME="$4" \
           -e USERS_MAP_FILENAME="users_map.json" \
           -e TEMPLATE_FILENAME="settings.template.ts" \
           -e MIRROR_REPOS="$MIRROR_REPOS" \
           gitlab-migrator

