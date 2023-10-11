#!/bin/sh

set -ex

#######################################################################################
# Trigger a test run from a plan using bash                                           #
# Usage: ./qualiti-script.sh <api-key> <client-id>                                    #
#######################################################################################

# TODO:
# Does our test-run-status passing in test_run_id and token still work with our new setup of using test case history items?
# Update all other sh files to do a similar setup

API_KEY=$1
CLIENT_ID=$2
BASE_API_URL='https://api.qualiti-dev.com'

if hash apt-get 2>/dev/null; then
  if [ "$(id -u)" -ne 0 ] && hash sudo 2>/dev/null; then
    sudo apt-get update -y
    sudo apt-get install -y jq curl
  else
    apt-get update -y && apt-get install -y jq curl
  fi
fi

AUTH_TOKEN="$( \
  curl -X POST -G "$BASE_API_URL/public/api-keys/token" \
  -H "x-api-key: $API_KEY" \
  -H "client-id: $CLIENT_ID" \
  | jq -r '.token')"

# Trigger test run
TEST_RUN_ID="$( \
curl -X POST -G "$BASE_API_URL/integrations/github/1/trigger-test-run" \
  -d 'token='$AUTH_TOKEN''\
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
  curl -X GET "$BASE_API_URL/integrations/github/1/test-run-status?token=$AUTH_TOKEN&testRunId=$TEST_RUN_ID" \
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
