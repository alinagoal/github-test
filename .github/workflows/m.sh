#!/bin/sh
set -ex

API_KEY='30e6a6b3d46222da'
API_KEYS_URL='public/api-keys'
CLIENT_ID='b3e967461ee94519229727fd0450da06'
BASE_API_URL='https://api.qualiti-dev.com'
PROJECT_ID='1'
API_JWT_TOKEN='85cc2ec85907bb8642ea07ab3c01031f6e7285a9ce7f1b993bb1956dfdf85178cebccc2373f666c39f7bd79214c2fe0b8351e2a15b1f6ed7a81987e3edc04b6d7ba55100c425d7fe2793adc2c660cbf54d9f9d704d587c0e1266d6eee49e31d8946ac1c7aeb42d920cf74d90c59d19b73b6d6313fae4a41b750d0c55c1e456e3cf9477f8a390574570ffc8a789c46f2ffe357a2d0a38fdc268feafa8824202f270980da4b77081808f667ad152da325f27e88c58e9f59f4b55807bf36d556e1f5c96c4701613535610152afcad7b006b37b497bcdb2b61a201f23c8d64c3bf4f3ed04454ff11fc9ada0892fb9cc8f9eff0ff571342efa48d349c2c83b02a55d2fe1a3e575192009e5dd4e9f8a1974cac|3e9dd7893476b4f6d213fcb92c902445|0c0182b6dcbddc8f54fb01d4323d1ddd'

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
