#!/bin/bash

  set -ex

  API_KEY='64173bf63d003007'
  BASE_API_URL='https://3000-qualitiai-qualitiapi-ij1zt8k7llg.ws-us82.gitpod.io'
  PROJECT_ID='4'
  CLIENT_ID='c7405bda73e6c3a76c46b68c1be35ab5'
  API_KEYS_URL='https://3000-qualitiai-qualitiapi-ij1zt8k7llg.ws-us82.gitpod.io/public/api-keys'
  API_JWT_TOKEN='0e9ddb57b22ad98badd29a7f2a8504eada574c2e7f0579aea9944ae28dbd75af72d895ec0b3cd3ccd7ae548701147a0ac08505f13651cfd0c98161b96ae065295322e368b2faed2f1fa2c7d75a7cc38c4fded33c094fbdca5d6e068296eacee35d2389731e0604bde15c8e7732798cb91c15f034060d13f38a57a31fe61ca8d15e3a270e5b3aeee6a292f1286fc66a166ba1f999e00acd6e0c3ecaed8d87209b91a0fd9b384eb74b959bcf56e10d10674320113d0361f6baf9c18a47d5b5645aa395ebcc51fcf89ae9f47a67315fc3557dc49846a20c39ef28c0e93a408dbfd06838fe067cf520ef9d5e97ea627e6020b39bf6655b1c764c356043acbc3cbe17e0dde1316638d872f3c9cc8041dc09b3|60b210db6769584ba70e251ea1fd02e5|176df8c16526d1047143dc0927fd48a1'

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
  
