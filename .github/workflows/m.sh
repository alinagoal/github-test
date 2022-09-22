#!/bin/bash

  set -ex

  API_KEY='5961c28019468d4f'
  INTEGRATIONS_API_URL='https://3000-qualitiai-qualitiapi-hmbmysbrjzw.ws-us67.gitpod.io'
  PROJECT_ID='1599'
  CLIENT_ID='8193833c9b9163b18eb654104d4f60f2'
  API_URL='https://3000-qualitiai-qualitiapi-hmbmysbrjzw.ws-us67.gitpod.io/public/api-keys'
  INTEGRATION_JWT_TOKEN='c637d8cc8951380fd9d67f23f3dab18cc33d6b8c4b2327d59b7ac3add0398fad43b4078793b21bfb0bc0e174e4f32ae15b56b02fce234397e41ee040a57a8efc398ecc77340972ce2343977c99832a23a59d7432f96cb4fe68febc838554cf4cd2962c04539b5e3b67984f4766b1ac3a7618817e43a82579e9dc0d115c7663f16901828b25a109d5b8d2d038c9f477b5083e04942cb4288303d5ea65514c839743dfb8ad456929bdb91dc60444642e4c3f760a2fc71914340de5c8b107741987ac8cc38a8025f1c411c04fa2ff1b4828b43f2e6fdc1cd76f5f6b329222248be22b4d5619fa0c50bb180b3dd23079cf3f689917a1ab5052cb9219177423b6166ee897fcedcabbf260c383ae50593a2574|f49799c0c825b69a46648bbddc950dcd|87891c3d94ab0464e4d82d7d6877b844'

  sudo apt-get update -y
  sudo apt-get install -y jq

  #Trigger test run
  TEST_RUN_ID="$( \
    curl -X POST -G ${INTEGRATIONS_API_URL}/integrations/github/${PROJECT_ID}/trigger-test-run \
      -d 'token='$INTEGRATION_JWT_TOKEN''\
      -d 'triggeredBy=Deploy'\
      -d 'triggerType=automatic'\
    | jq -r '.test_run_id')"

  AUTHORIZATION_TOKEN="$( \
    curl -X POST -G ${API_URL}/token \
    -H 'x-api-key: '${API_KEY}'' \
    -H 'client-id: '${CLIENT_ID}'' \
    | jq -r '.token')"

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
      curl -X GET ${INTEGRATIONS_API_URL}/integrations/github/${PROJECT_ID}/test-run-status?test_run_id=${TEST_RUN_ID} \
        -H 'Authorization: Bearer '$AUTHORIZATION_TOKEN'' \
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
  
