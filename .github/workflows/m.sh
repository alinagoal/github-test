#!/bin/sh
set -ex

API_KEY='f7b369f2c6ff6282'
API_KEYS_URL='public/api-keys'
CLIENT_ID='c6c6f311c3a65a8da477b48ccc9afe05'
BASE_API_URL='https://3000-qualitiai-qualitiapi-9dm871pa41g.ws-us105.gitpod.io'
PROJECT_ID='1'
API_JWT_TOKEN='0b72b6a0281d4b6e1f6dced629d967322e4d27741492d55b7df37367427f100fee0ef39a78421bc7e3e0ed16f10777ff1fc0a0bc89b97ab1e0078f7a0b335de1a0195c76df9e45fcbd8cdc8f5bac2099eb0f4618a74d8ca5a4ebefb7509ffb32f6392ccae27d2b80401b9b8a25ede569b4812a06ad3775e95e57b445b12c985889d815251d7c55e956bc4823b55f107c0c4b198fbaf336d1e3b5d022f4ece26337996d891822c5e4831501a4cdd6294f26face2e6483858c6aa390e5245ff4a1df47e844549a423b3c1a2a488849e132691dee0f996d3b5d59a7e50ef069ef76eb4fd6638b7bef570fde16b3c8be67e88919783591b7c79f4d187994c8370ce356fc71fad53b352e07b8093a15fc524c|7abdcff383be6ca60ce1c9744b8dbbbe|c4fedddf178f99b3b5f1c3fc68ad4654'

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

if [ "$TEST_RUN_ID" = null ] || [ -z "$TEST_RUN_ID" ]; then
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
