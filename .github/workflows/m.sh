#!/bin/bash

  set -ex

  API_KEY='b98670c724e80881'
  BASE_API_URL='https://3000-qualitiai-qualitiapi-7qrlxhwdm3i.ws-us84.gitpod.io'
  PROJECT_ID='4'
  CLIENT_ID='2bb10a50533f7b0d2a37f200dd0055ec'
  API_KEYS_URL='https://3000-qualitiai-qualitiapi-7qrlxhwdm3i.ws-us84.gitpod.io/public/api-keys'
  API_JWT_TOKEN='d84b4e7ebd074a35b0fdd3e92d9f0f85eb9848d6a80c4e6b5a2bcf99d5d0a1206ce41704680043486bf71f364acc2851fdef708732e7c7ff87dcd52c52c1ce0c41f5482aa6b952a2a103743bfa79005313a9785d131fd172d28aa0b625b9e4ffd8d01c82911116ee50d60c23d5b884ed0abd884c9e5bb97501670f3bdced79f4493ff900d9d54ac6f408ad8f0c6e2c7de01d3fcb830b4175aaf2df8192a8a46ed9d83e7d1006e2f2293a1b633d121277848b7aa158bf91189d19eb635c5c80bce3d39b7b2e1d7c7f1a7cbf649ea2e96e26db7708f844bac8dd79b40ef37d9158b0da2af7700ea492c20ca08485436bf97b15fd620d6f87aea790a39290b794e3c28815339dbcaa22a720d221b48c71da|5f4c5250df1235ddfa9da4129084483e|d06ebcfb4f6d3712ef16ea6b3a02e552'

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
  
