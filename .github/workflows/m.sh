#!/bin/bash

  set -ex

  API_KEY='14fbbf402317abc1'
  INTEGRATIONS_API_URL='https://3000-qualitiai-qualitiapi-xfbrsf11r3p.ws-us63.gitpod.io'
  PROJECT_ID='3'
  CLIENT_ID='a5cdd625fbd159e02ecbd8021af509d8'
  API_URL='https://3000-qualitiai-qualitiapi-xfbrsf11r3p.ws-us63.gitpod.io/public/api-keys'
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
    | jq -r '.token')"

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
      curl -X GET ${INTEGRATIONS_API_URL}/tables/test-results/${TEST_RESULT_ID} \
        -H 'Authorization: Bearer '$AUTHORIZATION_TOKEN'' \
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
  
