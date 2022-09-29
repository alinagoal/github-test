#!/bin/bash

  set -ex

  API_KEY='c3e7e92be76bb378'
  INTEGRATIONS_API_URL='https://3000-qualitiai-qualitiapi-hmbmysbrjzw.ws-us67.gitpod.io'
  PROJECT_ID='6127'
  CLIENT_ID='8ce1dc9a0f3fd89014044f94082a4c46'
  API_URL='https://3000-qualitiai-qualitiapi-hmbmysbrjzw.ws-us67.gitpod.io/public/api-keys'
  INTEGRATION_JWT_TOKEN='acf9561e73a8757964ce8c4e04c2abc436724f1ad22cf88343334e609766744741e8fc313f2dd8a23c08b07470cfd68104f80be760ba09d21dbe5a7cffbe1836c52bbd9fa124a0489098b56d084425e6617f9025210b51d22ce64d44bbb092f87fe5f0c116b6678730027128668541b0555ea94aa7921f243c7d30abbbaca391b8b2367f6a1f7ea62edddb346f7e4ae5941031faacce8893db7faf6ace1ff48601d24179a04887695e8858a4c3d1103e1b8acfda801601c0ad1250a876262c83f4a1a9718bc91026b2e184c42e8efe04f7b70e25f13020624c42ca0207bbb8b165710e49dc22863a28af8f965c5af60667eec778b1fb891fd68ec37e2d02a094aa4b779f64f7d4a2f4eabcb5d2f30443|f3ae8d55afc77c347672a5f1c8f42ad8|3c5fa0eded3f8bd3e0609e365132b386'

  sudo apt-get update -y
  sudo apt-get install -y jq

  #Trigger test run
  TEST_RUN_ID="$( \
    curl -X POST -G ${INTEGRATIONS_API_URL}/integrations/github/${PROJECT_ID}/trigger-test-run \
      -d 'token='$INTEGRATION_JWT_TOKEN''\
      -d 'triggeredBy=Deploy'\
      -d 'triggerType=automatic'\
    | jq -r '.test_run_id')"

  # Wait until the test run has finished
  TOTAL_ITERATION=50
  I=1
  STATUS="Pending"
  
  while [ "${STATUS}" = "Pending" ] || [ "${STATUS}" = "Incomplete" ]
  do
     if [ "$I" -ge "$TOTAL_ITERATION" ]; then
      echo "Exit qualiti execution for taking too long time.";
      exit 1;
    fi
    echo "We are on iteration ${I}"

    STATUS="$( \
      curl -X GET ${INTEGRATIONS_API_URL}/integrations/github/${PROJECT_ID}/test-run-status?token=${INTEGRATION_JWT_TOKEN}\&testRunId=${TEST_RUN_ID} \
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
