#!/bin/bash

  set -ex

  API_KEY='23797e7b4f003590'
  BASE_API_URL='https://3000-qualitiai-qualitiapi-ogivbxmnwod.ws-us82.gitpod.io'
  PROJECT_ID='3'
  CLIENT_ID='c73f0f90c2a064efec5b411e0df236cb'
  API_KEYS_URL='https://3000-qualitiai-qualitiapi-ogivbxmnwod.ws-us82.gitpod.io/public/api-keys'
  API_JWT_TOKEN='3efa23ef0932beaec3ba011bf5c104e07931f753eaebdf56a6ab5f651e2d840f6bbbd85fa1f126a10e828b963516e0a2996a80f6a7ec84ed53a5769ed2975f45037ed7bc14e67e205f6b2baafaec925b8ad6202fc8923f4c453d502bfb8ea171db9f4b97eefe6924b8b2820d32bc4764f440c823d3aed746687010f5d430dbf91e0d0f839ed1f8e0d04d998553a53923357a1b33dec174532e0d71242e5c4d40877ab2afc8daa9fbd0bc54b34c047c13d9aab314ec8bbca546b7d0c6d55d26efcffbafc8be7241f28a8f55478c706ae2adb6f5a938c944d074fbc3d6ad4c876f98b55b31df0e422c76098ffb0de8c3dee8e204d03d475cae48c21673ae74f4f05d81d5760906c124154ed096925224c7|0a235a77bdf4378ac716ba1caa8f159e|4bdecadc0acd6515c5e73c5d4fad5f58'

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
  
