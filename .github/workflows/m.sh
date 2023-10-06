#!/bin/sh
set -ex

API_KEY='b85073ba18c335b9'
API_KEYS_URL='public/api-keys'
CLIENT_ID='b3611bba09caa796f7b295cf6f29bd8b'
BASE_API_URL='https://3000-qualitiai-qualitiapi-bregtn5ubga.ws-us105.gitpod.io'
PROJECT_ID='3'
API_JWT_TOKEN='87fac20aa0002e0105667e975850158916cc79a5b8fd4e8b28eed26c549138854e320b333a9482b0bf6b1c4f7c9fff0c236337d0b8210134d959818a23d35dfa7468706313b50ec28dcb2aa75e09cfc8be79d50bf2ff573f331d5fca1c1a32206e1ab50f1be951395633d6a737d3050990d4a92d34a55135b3ba21e8cf09221bdf3dc5b89a03383c0af934f223290a4f47a2ea1d0987b297d77474ed5abe7c1e8e05b6ad6a5f40aeddb0c4887fd3ee9883959dbe0cbbf5ce3997d11794ca35da183612a5239304f382b37b92cea547db775b62fce56e0ec1063df2a66bdcac83f34c6e554e016081505612e789e7a4a4ab51c8f65b4898e186969d9d54d2457056e0aaac13d1effd3bec194a0b0d94c6|70d1675a93b3c1d178ec89ef024c22ac|f904becb44c3d574c1306324e1ca5f63'

if hash apt-get 2>/dev/null; then
  if [ "$(id -u)" -ne 0 ] && hash sudo 2>/dev/null; then
    sudo apt-get update -y
    sudo apt-get install -y jq curl
  else
    apt-get update -y && apt-get install -y jq curl
  fi
fi

# Trigger test run
TEST_RUN_ID="$( \
curl -X POST -G "$BASE_API_URL/integrations/github/$PROJECT_ID/trigger-test-run" \
  -d 'token='$API_JWT_TOKEN''\
  -d 'triggeredBy=automatic'\
  -d 'triggerType=Deploy'\
| jq -r '.test_run_ids[0]')"

if [ -n "$TEST_RUN_ID" ]; then
  echo 'No test trigger found.'
  exit 0
fi

# Wait until the test run has finished
TOTAL_ITERATION=50
I=1
STATUS='Pending'

while [ "$STATUS" = 'Pending' ]; do
if [ "$I" -ge "$TOTAL_ITERATION" ]; then
  echo 'Exit Qualiti execution; taking too long.'
  exit 1
fi
echo "We are on iteration $I"

STATUS="$( \
  curl -X GET "$BASE_API_URL/integrations/github/$PROJECT_ID/test-run-status?token=$API_JWT_TOKEN&testRunId=$TEST_RUN_ID" \
    | jq -r '.status' \
)"

I=$((I+1))

sleep 15
done

echo "Qualiti E2E Tests returned $STATUS"
if [ "$STATUS" = "Passed" ]; then
  exit 0
fi

exit 1
