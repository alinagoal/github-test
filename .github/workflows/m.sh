#!/bin/bash

  set -ex

  API_KEY='ec99f5f8f0eae3eb'
  BASE_API_URL='https://3000-qualitiai-qualitiapi-7fumgmyq2sv.ws-us83.gitpod.io'
  PROJECT_ID='4'
  CLIENT_ID='cfd70e9344ea4419b9ae544b5998c44a'
  API_KEYS_URL='https://3000-qualitiai-qualitiapi-7fumgmyq2sv.ws-us83.gitpod.io/public/api-keys'
  API_JWT_TOKEN='0b883dd87ca96f8b65ddfef488b17a0c8092a3a72edabd6f0d783c438cbfd20ca5a1d7e327f31ede9ef4ff7e311e064d56403de9760e9419e9d3eeba37918ff1dde49741ca4b3c83c8a164a8ecaf4674eb6f20835f410bc4d21184e7486245f7d7777066ecb85078a5ce693be8d3620d06bf9a3978880f681af4fd16e330bd06161d316b5a7cfc8f7cf90c3efc8f8326809de2683a2fb62e929e531bb63d96e7a3a0fbd3b73abfb47a5666d4580f13975830379e0f85acebafbf9ffb5b9ec20720d424d02e0173d015463117aaf65c23f6f81106250755b44f7b78dd4a55f73b5cf385830afcbf936c09cc64512146f73aa803cc42f1822c578efd85c152506107828a79b0c134d8e966db6bcdb9579f|f8b9ee5f79e7f83bec24655377cdb6e8|5222cdfc9080beb3cd88088ceb2f317b'

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
  
