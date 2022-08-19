#!/bin/bash

  set -ex

  API_KEY='097b1ccb649deee5'
  INTEGRATIONS_API_URL='https://api.qualiti-dev.com'
  PROJECT_ID='3'
  CLIENT_ID='88b70bc343365e1f4ea9d1481f7cd18b'
  SCOPES=['"ViewTestResults"','"ViewAutomationHistory"']
  API_URL='https://3000-qualitiai-qualitiapi-n9q4mebz4h5.ws-us62.gitpod.io/public/api'
  INTEGRATION_JWT_TOKEN='9e3633a081dc4e5ac5a6fc4b3ca599a1a7d47629a600d8167a8e2215c0108e198ceae504bc7c045e39696ffbf17fb9d3c23f07abc80afd122f28c5ae59406d131a1c1a632d9a3ec12ecff968bd9ecf1149147c35fce0b24ba423d92d8cfc0f2bf56cf9b4f1b8c6f0ff40b456ebe742882ec18f472a204a469a5b0658716e15371965b69b57d8e620093c4c865af11c6a8305b48bef2f4ea86ab0c293b73b6cca3220d77d49e22764ca4e9999e2c1879a02ac4db596022902c3104835145c7a5df55c7b839d4ed52e2280ade21c37104d81ab2dc89a67c042f163f6a2bc7f494ac4c2f37e00d7999e65b170701491457cccb4226271209b6b6652489099772a6e9d2facb135031213d617b8366c5310a5|6109fb4c628f5739580f0fdd37ad6260|9858193e35eac9615c16a619efbcb6a9'

  sudo apt-get update -y
  sudo apt-get install -y jq

  #Trigger test run
  TEST_RUN_ID="$( \
    curl -X POST -G ${INTEGRATIONS_API_URL}/integrations/github/${PROJECT_ID}/events \
      -d 'token='$INTEGRATION_JWT_TOKEN''\
      -d 'triggerType=Deploy'\
    | jq -r '.test_run_id')"

  AUTHORIZATION_TOKEN="$( \
    curl -X POST -G ${API_URL}/auth/token \
    -H 'x-api-key: '${API_KEY}'' \
    -H 'client_id: '${CLIENT_ID}'' \
    -H 'scopes: '${SCOPES}'' \
    | jq -r '.token')"

  # Wait until the test run has finished
  TOTAL_ITERATION=200
  I=1
  while : ; do
     RESULT="$( \
     curl -X GET ${API_URL}/automation-history?project_id=${PROJECT_ID}\&test_run_id=${TEST_RUN_ID} \
     -H 'token: Bearer '$AUTHORIZATION_TOKEN'' \
     -H 'x-api-key: '${API_KEY}'' \
    | jq -r '.[0].finished')"
    if [ "$RESULT" != null ]; then
      break;
    if [ "$I" -ge "$TOTAL_ITERATION" ]; then
      echo "Exit qualiti execution for taking too long time.";
      exit 1;
    fi
    fi
      sleep 15;
  done

  # # Once finished, verify the test result is created and that its passed
  TEST_RUN_RESULT="$( \
    curl -X GET ${API_URL}/test-results?test_run_id=${TEST_RUN_ID}\&project_id=${PROJECT_ID} \
      -H 'token: Bearer '$AUTHORIZATION_TOKEN'' \
      -H 'x-api-key: '${API_KEY}'' \
    | jq -r '.[0].status' \
  )"
  echo "Qualiti E2E Tests ${TEST_RUN_RESULT}"
  if [ "$TEST_RUN_RESULT" = "Passed" ]; then
    exit 0;
  fi
  exit 1;
  
