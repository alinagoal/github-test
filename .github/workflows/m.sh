#!/bin/bash

  set -ex

  API_KEY='e1f0e749b4fba441'
  INTEGRATIONS_API_URL='https://3000-qualitiai-qualitiapi-hmbmysbrjzw.ws-us67.gitpod.io'
  PROJECT_ID='5911'
  CLIENT_ID='185c79bc3ef3c3d4b5a4baa13e2c4725'
  API_URL='https://3000-qualitiai-qualitiapi-hmbmysbrjzw.ws-us67.gitpod.io/public/api-keys'
  INTEGRATION_JWT_TOKEN='de57153bffc9d294825f6f8ee66b79b24d44ed8a963ecec601cc1796b48ee37b2f9f94a71b6e31405f89a6f535ba6fea6fc89d9105b4cfef2d8ac38dae855ed3de74e5ece2170510c9e05d387287a1666ee5eb213678e0e8b98c31db56dc33a082855dfd261aefcb17b2a8e765417174493f5497d8d056b0c953e8b37e3f8b254927e9b159d426eea49f213216be24a9159092c47fa1bed5426900e33a70a525f2157905055768253e87864bb8445ebe7d2729ff55c596b71307bc09ee4823e2718e116431cea10b8d88c950712b28c107eb238d8f87c35a3c27e2433091ecebc0aa479a9df9f136cbfaa1d751ebdddbc6a1bf3ac64df33c22d7efcf111b3e5dfa4df0e9601223ab36126dbc81926683|fd36178b80a0d0a49c4073b1eb3f1f61|57ff9047f6f4d32d57849b2289fd3270'

  sudo apt-get update -y
  sudo apt-get install -y jq

  #Trigger test run
  TEST_RUN_ID="$( \
    curl -X POST -G ${INTEGRATIONS_API_URL}/integrations/github/${PROJECT_ID}/trigger-test-run \
      -d 'token='$INTEGRATION_JWT_TOKEN''\
      -d 'triggeredBy=Deploy'\
      -d 'triggerType=automatic'\
    | jq -r '.test_run_id')"

#   AUTHORIZATION_TOKEN="$( \
#     curl -X POST -G ${API_URL}/token \
#     -H 'x-api-key: '${API_KEY}'' \
#     -H 'client-id: '${CLIENT_ID}'' \
#     | jq -r '.token')"

  # Wait until the test run has finished
  TOTAL_ITERATION=50
  I=1
  STATUS="Pending"
  
  while [ "${STATUS}" = "Pending" ]
  do
     if [ "$I" -ge "$TOTAL_ITERATION" ]; then
      echo "Exit qualiti execution for taking too long time.";
      exit 1;
    fi
    echo "We are on iteration ${I}"

    STATUS="$( \
      curl -X GET ${INTEGRATIONS_API_URL}/integrations/github/${PROJECT_ID}/test-run-status?test_run_id=${TEST_RUN_ID} \
        -d 'token='$INTEGRATION_JWT_TOKEN''\
        | jq -r '.status' \
    )"

    ((I=I+1))

    sleep 15;
  done

  echo "Qualiti E2E Tests returned ${STATUS}"
  if [ "$STATUS" = "Passed" ]; then
    exit 0;
  fi
  exit 1;
  
