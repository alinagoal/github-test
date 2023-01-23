#!/bin/bash

  set -ex

  API_KEY='28630e2be6fbd662'
  BASE_API_URL='https://3000-qualitiai-qualitiapi-7fumgmyq2sv.ws-us83.gitpod.io'
  PROJECT_ID='3'
  CLIENT_ID='5023b130bb377f7dbaff74976bc4a699'
  API_KEYS_URL='https://3000-qualitiai-qualitiapi-7fumgmyq2sv.ws-us83.gitpod.io/public/api-keys'
  API_JWT_TOKEN='d6e5161cca7c195ebaf05ec3ebb90d53026071da125be84bd20fe295a3a4e3ac9dfc7437f6d7f663eac28510755beccab906ecc2a137c4b4b6238b6dcf5497123c7ee183eeb3eb36b5cf6d781d43ad994ab926d3e214cb5a578089075bf4bdd88fc75c8b133364785456c20c47c43e93ce2c5bf41b0ec1e4f88be354d4e750b134f987d1aa18c90c448a12f56fb74d4ae7afee4489a5ca16b681172cdd7bf59d88acd93871a888c0ff1f0453b3d7f568f5fcde34c805f3ca020ee00c1bbf64a345d06ed1d74391ef552c227228b262f3507f48bdbebd253e6816619547c24a7e066495b6d3ccf7f47d1f21d4ad702a47faed010404c05d3ccccdc1d693a4b24e784ca3801c11e434e0f06fdb0cf775a3|a5e38702c6cbe8126de2d80d95fd95b2|0fb300f51036ef6ab80d83e2ba0016c3'

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
  
