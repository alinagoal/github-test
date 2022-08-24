#!/bin/bash

  set -ex

  API_KEY='1df2d88975bc9d4d'
  INTEGRATIONS_API_URL='https://3000-qualitiai-qualitiapi-m2ve15vx7ti.ws-us62.gitpod.io'
  PROJECT_ID='3'
  CLIENT_ID='32fd26217a831e878ea2418a06471814'
  SCOPES=['"ViewTestResults"','"ViewAutomationHistory"']
  API_URL='https://3000-qualitiai-qualitiapi-m2ve15vx7ti.ws-us62.gitpod.io/public/api'
  INTEGRATION_JWT_TOKEN='40a521b237f372bb2f3626c6b466864f0a7654cdd9aa2409d9e422b33d40c6b6dc6aaa15e6a4397d12022c00da1fe540ec946528d05e6f6293c25d53cdbd789f0ef75a6c893c486733f3df6a65c9c3d0312d11d40ca8af44dd2243d9cfabdfbe435687cd0593dc6bfa504dc454084e5630837a69a882210b5074215ad505c8a048bfbd37e3b25a5b76a42941193b96b0fad8cf95ee7e6d65cacccf321c0e31841bbde8b739fac5ac3fa7a26d0b67b6faa34971d199df68193cdb9e984980841d55926afaec5deb609d12db832ba0570fa3b94fa8ea16613af699af534fda0d075eb5e18be54313a2e147414637f68d5e1f85b7557e3fa023634e3f3fd495515e6018a2736156b3469eecf4f69f4a68f2|278a982a2a4d1928bdc2446c411f216c|4a186ee3a59ee4906ffd482e620b2f64'

  sudo apt-get update -y
  sudo apt-get install -y jq

  #Trigger test run
  TEST_RUN_ID="$( \
    curl -X POST -G ${INTEGRATIONS_API_URL}/integrations/github/${PROJECT_ID}/events \
      -d 'token='$INTEGRATION_JWT_TOKEN''\
      -d 'triggeredBy=Deploy'\
      -d 'triggerType=automatic'\
    | jq -r '.test_run_id')"

  AUTHORIZATION_TOKEN="$( \
    curl -X POST -G ${API_URL}/auth/token \
    -H 'x-api-key: '${API_KEY}'' \
    -H 'client-id: '${CLIENT_ID}'' \
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
  
