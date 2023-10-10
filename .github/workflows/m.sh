#!/bin/sh
set -ex

API_KEY='730d95cc11f9b633'
API_KEYS_URL='public/api-keys'
CLIENT_ID='6a875ed1f81e3ac96b65dba7a9fb61c0'
BASE_API_URL='https://app.qualiti-dev.com'
PROJECT_ID='1'
API_JWT_TOKEN='217c7df10b84d23ab6b70a91d126fe968d8566bc11b04e95abfa784ae1c17f50cb3113ad7c72b8306c772dac8b31cd8ef75f0bbd97ea529710e3808a531d893b7bf52ce9a1ca372823b33e24fc37b761d7d31d901a43dd84e9994f689e34a4a69aadf67e63502300b63a70ae2c26c660e47c13bfd5d1f092fe50fe22b55b2e37ac4c207e2eef3d739697a36c9179539033c600df962c98a7bd8b425f6e23eea01ff8ba224bf5d1673e100bfe50cd3132b3018d79e3070434c5d2add9d21ad480dc59ff215ce92d11359272aa13d7a9e3f98c7385ade08b113241fb34dd0c62b6547e30c4db0cf66c527b05df59afe1071fe242c3d0485561e9c1c1972034e0ecfbf78b6a281ce5de8a1e684d4e268ab4|da3a763b632add03c74e8e3cc87332ee|92a10e08c867c36f81780377dda2b0db'

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

if [ "$TEST_RUN_ID" == null -o -z "$TEST_RUN_ID" ]; then
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
