#!/bin/bash

  set -ex

  API_KEY='ae7fcd1d44311635'
  BASE_API_URL='https://3000-qualitiai-qualitiapi-7fumgmyq2sv.ws-us84.gitpod.io'
  PROJECT_ID='3'
  CLIENT_ID='daee5e499eea09c3f10ec3999602dcee'
  API_KEYS_URL='https://3000-qualitiai-qualitiapi-7fumgmyq2sv.ws-us84.gitpod.io/public/api-keys'
  API_JWT_TOKEN='1cf873066b4549f54937dbea87e49274a94c32d5b0d64bca8f2e4dd14e52e14a759d1cf8fac7c8573ceeb306b1b3f14d99d7a2bc7a55dbcb284aa8d3cb93c6c4ec15029b9698605e67c44b11bc4da2d96c737cefa244047f2c178582333dd838ebfb3a6b733dd60c320b61bd966dbb9063cb67d89ce80cfe83d847c68c29b36368618211344980eea27b29cf5da1e638b128cf2d6b67846f23942b795776a59b9a9c8e721c9e587512f685a97a17af54585895c8ae485f3f9f51a118c7f84ab64c7d09d747359e08a3d914bb3a35a38082ca21c3bf2d54855b1e92c596bfdde36ba3ab4815a47c03411d5e3b0c45f1951ec1e9154b4dadfc339701ceecec839d684e391374de4f9afd4da2f80137ef97|2079eb274f2ecfe33b6a362c64318de7|5416b00f4338f0d5eb759445108f19bf'

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
  
