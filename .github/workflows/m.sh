#!/bin/bash

  set -ex

  API_KEY='0ebb0697c11b3322'
  BASE_API_URL='https://3000-qualitiai-qualitiapi-ij1zt8k7llg.ws-us82.gitpod.io'
  PROJECT_ID='4'
  CLIENT_ID='618f38f79e4c88a9cd35b7f7b733de1d'
  API_KEYS_URL='https://3000-qualitiai-qualitiapi-ij1zt8k7llg.ws-us82.gitpod.io/public/api-keys'
  API_JWT_TOKEN='6fc99f0bda6dad0b55172e6616a6a21e59471438edeee364556ec40bbd5d6a67f32814cf80de2824f062e0a588c7de54354d93269eadfb46e80e9399e06f2137d0bdc3bbcf6a3c3b51f8cdab16c1769c5013510e8fe89c59f19be9f9d9c75d6ae48863d44ce94c8342be42a2a7554f28d819ec67568c333cdbc86cf501806f647e29ea549bac5eb76fa8af70d5b3e8c8f5e717b3340b9fb0aff78ad81d3c7aadd4d92f6e87c18391137ecea694df6ec25d60f11ee8d7f503482d03c08e87c7615875febf51334f1e19e9b98daf830bc172af3bff52ecdfcbf4cf8f71e8efabce3bceeafa331288257a63c9220d9538d6aaab3f01080e6930bcdcfa07105ea82953adafac96a27ba8d49bb5502d3ac2c2|736e31cdd79e8b5c0875c9bc58843755|532ec35286348fd0faf10506ff57f09b'

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
  
