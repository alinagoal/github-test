#!/bin/sh
set -ex

API_KEY='<REPLACE-WITH-API-KEY>'
API_KEYS_URL='public/api-keys'
CLIENT_ID='<REPLACE-WITH-CLIENT-ID>'
BASE_API_URL='https://3000-qualitiai-qualitiapi-bregtn5ubga.ws-us105.gitpod.io'
PROJECT_ID='3'
API_JWT_TOKEN='969ae959fd1cfb04f36ad0939c3be4e0118553b9c02ccb65c17464c506c21245e05c5d4d33eb28715b9b607f3c6befb3709daa71bdd4e70ae1c30421d4d88606b0827a6634c7315471d1fcda4c20221f306b5997309dd9fe3b3b7ee8c51f5a53d34016bb285d9bfe7cc5a183679f17eac58f23521d3c7370598517e0345224b31185f30b36ae1f18503b4dadacf0799646379a217653035de35bf1caa26913f08715b21a6a24ea40a50481e460fc0ee0dc23c009a6b9dfc5e04630c6640d0aab751c3256603837139254e2bac2b19d1e815c2cc9e245c2ee401cb828446689a2bf1bb5b0fa6eca0f96550196d021471af4a53c758c11e3ca7cfa32ba981368ced20173ee0629143014685d56d797dad5|a8fe62d7bed943b78a86cfe72d74fd5a|ab8239dba908ccf2dc630a5201876008'

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
