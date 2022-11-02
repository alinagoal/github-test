#!/bin/bash

  set -ex

  API_KEY='ec14f0c5726efca5'
  BASE_API_URL='https://3000-qualitiai-qualitiapi-xu780dcs2ks.ws-us73.gitpod.io'
  PROJECT_ID='8052'
  CLIENT_ID='3f2982277e5968c5cb77c9fdda0937be'
  API_KEYS_URL='https://3000-qualitiai-qualitiapi-xu780dcs2ks.ws-us73.gitpod.io/public/api-keys'
  API_JWT_TOKEN='e4753d4b93b76eba5e64d77d2d6178469806b6260c54d893965e213ac72d7704854dab4d9c8c36a87bfeb80f67f5cbdb6fa0edea79d755034f4e24ddb47f2b96db541070c070d66445789554b28ffb877cbff9f5650c9dc2b0e178d2a02916a007d0ece8b77aa78df8d5b3c98c1d818e1b572fc60ac9c86ae80a809f09d84ea5289ced592571fc82dae3a45626dc1678110dc715697f087443ad5933b0ae69f1bc98f52b9351295aada23b84871b7986e987098294ca8b1a7390c4658ca05fdd2e1a52590406a510cf884a6df8f031e8ca341a340c166293f21de0553f8ccb71f1a7b40a9db322301ca43eeb381f6d0e67404cc49509bda6e3192e810d60753da8eac87c1ba3649b92d210f824958798|af862a87c3361814ca04a9e6e7b39e61|85a57830587956163d37f7c2163e9c09'

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
  
