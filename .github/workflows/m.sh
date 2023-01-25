#!/bin/bash

  set -ex

  API_KEY='0c678e541a090d83'
  BASE_API_URL='https://3000-qualitiai-qualitiapi-7fumgmyq2sv.ws-us84.gitpod.io'
  PROJECT_ID='4'
  CLIENT_ID='bb4857b2889df6d9ae8781e19bd81ef0'
  API_KEYS_URL='https://3000-qualitiai-qualitiapi-7fumgmyq2sv.ws-us84.gitpod.io/public/api-keys'
  API_JWT_TOKEN='074514fa549a088b710b53585b945569aefd4acdb1ce206b010c1eeb9a7974e0f831ebb6741d501f241d0a0983f488a0346f40399e42669bb4742cc3247dde7cc1d01d7317bf024f8731ea90ce0a1da06bcc3533437bcaf3916bd9d52a9e7c9f4f22901b184a45fe665d77b3cced48f40f4683d4287739dd5fc2d5c5afa240de7c2bf02d0f9c110f6d500b134bb64c6ff2e43eb4918852304e754cd6040867f0a7b1c91b995d84d8c4360f1bf2c23f051dd22a8cd7fbf684d258f6688b3211a01186dfa9a22f607d0453911515a2d86e5d67903d494dfa54e4f9d44401927c14a1f704d39109983c3814921267faf13e7720cd008c7b45dbe8ebde2ec603bd0e51718cffe2129af27699e9fd1e400762|f797a1f914cc712fd63b95ab921153c1|687095a6a893932ea501a9ab33d98932'

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
  
