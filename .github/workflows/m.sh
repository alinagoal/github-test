#!/bin/bash

  set -ex

  API_KEY='14fbbf402317abc1'
  INTEGRATIONS_API_URL='https://3000-qualitiai-qualitiapi-hvwg6w2mctw.ws-us63.gitpod.io'
  PROJECT_ID='3'
  CLIENT_ID='a5cdd625fbd159e02ecbd8021af509d8'
  SCOPES=['"ViewTestResults"','"ViewAutomationHistory"']
  API_URL='https://3000-qualitiai-qualitiapi-hvwg6w2mctw.ws-us63.gitpod.io/public/api-keys'
  INTEGRATION_JWT_TOKEN='e86d38dc98e9c9eba59700a50f310bfa8d67b68b2246089d88a9a48d4a2db9e36b1bc0f665cb9af4a5e9f838261eae8f9aa8c986ef35a796d4401aee77547d5f35c975ba14d30991626129ea9e3b2a646022b5d5b781ac15807fce1d0370774605544fd4507c9417d8386678da48404901bbf49aba4db9d6c3aa976f08e4ea7adfc8c46143cc78be76ee8ecad81e7c3c60936a892cf8a0c020e62d7447d3ce113ae34b9b7516b2cdf08a8f6a69e840a4824a04b4e4a9333a3a492a5f908c01d439c3ea61678064be7fc5fb161d9b518fca9759be8e718dc30ce6fef0cff9bf756bbb1b368bf0e726b86fde6dbe4bd4a7b38f13f8a994372d59809f8d15d8f6ec21b234576c7668bf4033ede238613f69|161e3dc9563a4ca779deffc618b4ded6|b2da3727a14e97469b1e8d520ea7dd3b'

  sudo apt-get update -y
  sudo apt-get install -y jq

  #Trigger test run
  TEST_RESULT_ID="$( \
    curl -X POST -G ${INTEGRATIONS_API_URL}/integrations/github/${PROJECT_ID}/events \
      -d 'token='$INTEGRATION_JWT_TOKEN''\
      -d 'triggeredBy=Deploy'\
      -d 'triggerType=automatic'\
    | jq -r '.test_result_id')"

  AUTHORIZATION_TOKEN="$( \
    curl -X POST -G ${API_URL}/token \
    -H 'client-id: '${CLIENT_ID}'' \
    -H 'x-api-key: '${API_KEY}'' \
    )"
  echo "AUTHORIZATION_TOKEN= ${AUTHORIZATION_TOKEN}"

  # Wait until the test run has finished
  TOTAL_ITERATION=200
  I=1
  while : ; do
     RESULT="$( \
     curl -X GET ${API_URL}/test-results?id=${TEST_RESULT_ID} \
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
    curl -X GET ${API_URL}/test-results?id=${TEST_RESULT_ID}\&project_id=${PROJECT_ID} \
      -H 'token: Bearer '$AUTHORIZATION_TOKEN'' \
      -H 'x-api-key: '${API_KEY}'' \
    | jq -r '.[0].status' \
  )"
  echo "Qualiti E2E Tests ${TEST_RUN_RESULT}"
  if [ "$TEST_RUN_RESULT" = "Passed" ]; then
    exit 0;
  fi
  exit 1;
  
