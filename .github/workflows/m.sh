#!/bin/bash

  set -ex

  API_KEY='aeb6733b2648a123'
  BASE_API_URL='https://3000-qualitiai-qualitiapi-7fumgmyq2sv.ws-us84.gitpod.io'
  PROJECT_ID='4'
  CLIENT_ID='4c3d6b881f3f45f7af5d6178ca965807'
  API_KEYS_URL='https://3000-qualitiai-qualitiapi-7fumgmyq2sv.ws-us84.gitpod.io/public/api-keys'
  API_JWT_TOKEN='65be562259adf1d2bc43a06bb1b1f87fe5a76cc9aaf74e078461a3ca4b6d5738c137cbc00411d8f90feb6c40f24f862c079931b7b6aa15145929c8ddbe91f788e8bb17d2bf5122bd0f3320263120b0ec3678ea2d0cf2e5df355d2d8fef3ea0432089fa05cca5f419d595ba80a2b648dba6977c9d6b4be0bc591ba1a0ebec41e248dc5e77732b1f095e8599183d28787ef3e955b293ad71086e0c1852f145c8bb9e95168330efe292f86e694d2a6c9915974c7987b804352884319475b394b4168c3b8c893f4bfd339a01bfe4bc2e04e0559aed912ee63af1e564cc8a33949daaa9d1c7a510a976eda873b373e0a2048f30303c7b0281b1bd23a180f4b23d06ad99ed140db2e73999b2609d5302a5787d|82798f0898af158ae8de9de873c091f2|6e7b0a3d76b13162b67f4fab3f7383df'

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
  
