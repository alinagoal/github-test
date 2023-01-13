#!/bin/bash

  set -ex

  API_KEY='359dbfef752d5b5b'
  BASE_API_URL='https://3000-qualitiai-qualitiapi-ij1zt8k7llg.ws-us82.gitpod.io'
  PROJECT_ID='4'
  CLIENT_ID='3c80fca6c0deada7e8a9dd45532e8f29'
  API_KEYS_URL='https://3000-qualitiai-qualitiapi-ij1zt8k7llg.ws-us82.gitpod.io/public/api-keys'
  API_JWT_TOKEN='ee33d22399bd3f9b04e18355b66ec99fd61e39dc3d3dba0869e84e1b097237033be78d99c7dc2bc3c9502a407b6a1644d188336a78e8de76fc9c39b5464c1f592acdc46545beccf48f3b54ca31a3b85b1dc12c1ee6fa597adeb9d448f54cd5a41b92e94cc5d6c1b280c2e124f4b367575010e8d68a1bacab88d192275ffe41e546926e6b97a13ac7691fa9141d0b26ebada9850c0a131fe4f3808e90d3864ce0489a46f5f95ef4049cd1ddc0f6738cbbd9c10e9435600d8ba1fa1ea689da58ea9e511cdc2ff8fdccf07fac422254cee60ff6e4d247250af023ed7f22d97d1f530a11115649f5864545d809679ab00ae23d8a18ede19a710c863bb35a4f9c94d13160c5bf59092752cbe67ff9e20e2d17|007fe55a1614d20110b0eb87c0e0be92|20d520b85257ccfb53371ebe96b81b16'

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
  
