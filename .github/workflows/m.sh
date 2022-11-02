#!/bin/bash

  set -ex

  API_KEY='275583b17e83b3b7'
  BASE_API_URL='https://3000-qualitiai-qualitiapi-xu780dcs2ks.ws-us73.gitpod.io'
  PROJECT_ID='6232'
  CLIENT_ID='c492aa830fc7f4718d0b3f038266e5e4'
  API_KEYS_URL='https://3000-qualitiai-qualitiapi-xu780dcs2ks.ws-us73.gitpod.io/public/api-keys'
  API_JWT_TOKEN ='c7eb9849d07254c7179eb2a2339d6e2430f8938eb392b4ed58de5357aabae3f1056e939240419034972a0f06d8c404bfd60bb8c991c7db42f41cb2361e055448513ef82315cb2068061f45745b08e0f91d346c2127c0dd76edc5703b32ecf51f4890e2997a0204560bf7ab6140dd9c22159376f9a584cf46df8b0150467146760b1e20837cee8a90e21f5e049d51f45ca997f52a270519b93621729586f9b14029e6e549abb936ead8562a07a991fb59cc78596de25de20bc87cc6a27f1d5b95a29f87a90db258eba5cc365760e9d18ec24bfedb7919d7a84fd2724021f1042114a691f7f1e15126f25801491a91dcbf14279e88ec8cbd69084591dcc6721c138285dfcf9aef6ab9499c5a7e7acff740|947060d8d59c3749ce193d7171fbec86|2696b92e9808687802f53850948f67b2'

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
  
