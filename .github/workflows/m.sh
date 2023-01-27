#!/bin/bash

  set -ex

  API_KEY='ea557998cf9a08af'
  BASE_API_URL='https://3000-qualitiai-qualitiapi-7qrlxhwdm3i.ws-us84.gitpod.io'
  PROJECT_ID='3'
  CLIENT_ID='133b1c00e317dc0f3b04f7cc070c73ac'
  API_KEYS_URL='https://3000-qualitiai-qualitiapi-7qrlxhwdm3i.ws-us84.gitpod.io/public/api-keys'
  API_JWT_TOKEN='1c117c29aa339aacf28cd706b65ad7bc026429fb6bb5b84b19541a320a7323f8ff2baa38758bc5345dfcf31835a0f0bed35a808c138b140ad4865c7cf55e241770df7c467cdf8e299f89d2c14f7d1ae89e27ec6b4b6735965509864b649c43ee003f2562fc30cf4aeddff41b0e850df7d6e3557596db1959f47aa402a83862a1fba55d8b76bb5d554116e4e5530890afeafc875388800ce7308affe4f46bcee60743efe726aab7e549e859ded0f2662fe9988ec415b7418d19b4189d8578a4265ae1d545a81eb5f458af6537548d37e02e18b9c0bc781126aae4246597702d8631577152feba6f119a8f24bd3ed66976c30a9a39752fc28a2ad83d4079ca014957438600ccf91ef3b69e84b2deb1fcf2|6f163a916731a26f37a14227d888a9e6|2197aaad61fbfac68101828796bc8064'

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
  
