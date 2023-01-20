#!/bin/bash

  set -ex

  API_KEY='83fe49db642263cb'
  BASE_API_URL='https://3000-qualitiai-qualitiapi-7fumgmyq2sv.ws-us83.gitpod.io'
  PROJECT_ID='3'
  CLIENT_ID='78ec45490fdd378646bb98d0d69db869'
  API_KEYS_URL='https://3000-qualitiai-qualitiapi-7fumgmyq2sv.ws-us83.gitpod.io/public/api-keys'
  API_JWT_TOKEN='08e3f8c8e06d6a7f21c8b078ffdf154fec50f42779f93a9ebdc58f30a990c3e8ca51ad5fb0a34a975764880738e97415f71993449d52f908719890c78dae2c8f89fbb1667cf21040fbf20f9d97bf83835d1abc69f721d6f34ff33acf06ad5902b6ac70c47cac6ff359cd845b0bbc09452c62d68782cabe87ab7029e37336bfd96741ae904fc52ebe9da524c6cb3f7f16d79e24137eba29978e792da1cf85086049b1439c7a49a7508ba11bdc3ecafe6a4ce6d2394c55cce17353c6f18e68ed6783ed282e60cff4f099700cf1e95625b054c8c8d2e72b13f10410858b1fbd790413af7e42189b135661847119f4063dd708935aa664e13d29489e49784eba132f3f61cd1a684071c695365ef153c5dffa|041a8cbe2b66673558adf44d0f4ab22a|d5c924e08926920c276522d387c93854'

  sudo apt-get update -y
  sudo apt-get install -y jq

  #Trigger test run
  TEST_RUN_ID="$( \
    curl -X POST -G ${BASE_API_URL}/integrations/github/${PROJECT_ID}/trigger-test-run \
      -d 'token='$API_JWT_TOKEN''\
      -d 'triggeredBy=Deploy'\
      -d 'triggerType=automatic'\
    | jq -r '.test_run_id')"

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
      curl -X GET ${BASE_API_URL}/integrations/github/${PROJECT_ID}/test-run-status?token=${API_JWT_TOKEN}\&testRunId=${TEST_RUN_ID} \
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
  
