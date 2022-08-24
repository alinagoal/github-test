#!/bin/bash

  set -ex

  API_KEY='<replace-with-api-key>'
  INTEGRATIONS_API_URL='https://3000-qualitiai-qualitiapi-m2ve15vx7ti.ws-us62.gitpod.io'
  PROJECT_ID='3'
  CLIENT_ID='4e8d6ce61e03c393cb968cb09ac84cfc'
  SCOPES=['"ViewTestResults"','"ViewAutomationHistory"']
  API_URL='https://3000-qualitiai-qualitiapi-m2ve15vx7ti.ws-us62.gitpod.io/public/api'
  INTEGRATION_JWT_TOKEN='665b89c53f229f9c410dee5b870069c04107015afd6d3a7620417fde94df136b0fa380f7ac9c6584f770ec35ab99c8d9a0ec6f70e46c52ae03b74077e52c8cbc6c72e6b6524105889e6cfcfd3165c43d75f6dbbb6b72e529d845a2e057176956a940b9c2e84d2bef2e2348e2c6c078ed5bda2ff904fea9b86cf72aa98841e4351ecb8ebfccbe1e309c7560634d8fb502a2a8beb7965f75bec04fd0d2878aad411808bee4c502c63787accf586120728126e8d682b8495f7467cd4e178eeffc9bfbef9e44355ac1a5eb174ec3dfecc152b76c82d19d842fc7068881f411a7cb0383cdb20ff8c9483f9f71c1c1053cddce0353e25cb68437793346fd31437a7fa5d95f3ee94d737c27d722eb5650d8faa2|57b755dd98672df46ac0ea4ae28a82f6|b3664244a450ddfc26588e3b5597e519'

  sudo apt-get update -y
  sudo apt-get install -y jq

  #Trigger test run
  TEST_RUN_ID="$( \
    curl -X POST -G ${INTEGRATIONS_API_URL}/integrations/github/${PROJECT_ID}/events \
      -d 'token='$INTEGRATION_JWT_TOKEN''\
      -d 'triggeredBy=Deploy'\
      -d 'triggerType=automatic'\
    | jq -r '.test_run_id')"

  AUTHORIZATION_TOKEN="$( \
    curl -X POST -G ${API_URL}/auth/token \
    -H 'x-api-key: '${API_KEY}'' \
    -H 'client-id: '${CLIENT_ID}'' \
    -H 'scopes: '${SCOPES}'' \
    | jq -r '.token')"

  # Wait until the test run has finished
  TOTAL_ITERATION=200
  I=1
  while : ; do
     RESULT="$( \
     curl -X GET ${API_URL}/automation-history?project_id=${PROJECT_ID}\&test_run_id=${TEST_RUN_ID} \
     -H 'token: Bearer '$AUTHORIZATION_TOKEN'' \
     -H 'x-api-key: '${API_KEY}'' \
    | jq -r '.[0].finished')"
    if [ "$RESULT" != null ]; then
      break;
    if [ "$I" -ge "$TOTAL_ITERATION" ]; then
      echo "Exit qualiti execution for taking too long time.";
      exit 1;
    fi
    fi
      sleep 15;
  done

  # # Once finished, verify the test result is created and that its passed
  TEST_RUN_RESULT="$( \
    curl -X GET ${API_URL}/test-results?test_run_id=${TEST_RUN_ID}\&project_id=${PROJECT_ID} \
      -H 'token: Bearer '$AUTHORIZATION_TOKEN'' \
      -H 'x-api-key: '${API_KEY}'' \
    | jq -r '.[0].status' \
  )"
  echo "Qualiti E2E Tests ${TEST_RUN_RESULT}"
  if [ "$TEST_RUN_RESULT" = "Passed" ]; then
    exit 0;
  fi
  exit 1;
  
