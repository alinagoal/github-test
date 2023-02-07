#!/bin/bash

  set -ex

  API_KEY='997ee3e469436785'
  BASE_API_URL='https://3000-qualitiai-qualitiapi-4xn5d8zaxur.ws-us85.gitpod.io'
  PROJECT_ID='4'
  CLIENT_ID='e4e56dedc9ceb135b2b45c3f2e3bf2b1'
  API_KEYS_URL='https://3000-qualitiai-qualitiapi-4xn5d8zaxur.ws-us85.gitpod.io/public/api-keys'
  API_JWT_TOKEN='e680cedebbd2595081a78b54050dc07d4a4144872902302af910f4e4c884ba1dea01a30119826d7117886aff6f81f7bc4058e88ce8bef5bfa58fa91eecb5d1c44c6de3f688c6e6cbf8a0598cef363d489dced0ac18aed6e9bf4c148cb3e37c2779e9d03b9fbfaebbccfa856a5cb66de12c14bf79778d53ce8fd5ac0c0d1747bcf2ecbe2c8647740c63c45bacad49b82e5c5adfb4b1a2a8a2ee79602283b73deb04efb087f9bf8b038d14d54fed13ef467c55dc646bf6810a076c9a80ab966b128316b1c866ba0a344deee31220b2819b8403f7e9f1295908859fe880804471a7759cf3db97a564c179e4576a3200df9d192d76ef9d2fb93dc8a46ecb77241e0b32e4c71d7a01ccce42330518f4ff66c5|fd20aff932543476429dcb2745579d4e|6f8cac2ebab3ea1a61cada00a42f0f80'

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
  
