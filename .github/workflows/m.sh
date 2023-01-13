#!/bin/bash

  set -ex

  API_KEY='01e08a968f504e01'
  BASE_API_URL='https://3000-qualitiai-qualitiapi-ij1zt8k7llg.ws-us82.gitpod.io'
  PROJECT_ID='3'
  CLIENT_ID='4fac1183eb48b0bf20a62424268e1fca'
  API_KEYS_URL='https://3000-qualitiai-qualitiapi-ij1zt8k7llg.ws-us82.gitpod.io/public/api-keys'
  API_JWT_TOKEN='7ade8b16ec252b5dc7416fd361287696e1ae6623886b4c2df2da3551b4be3d1133db9ec71c7a44e4d6c4d466f67689945bdfd389716cd8cb92671b0954e3b375bfeb53a05a19391d31cd9b106758c4ace1a855b531e00ee5f90c39d90197ec00d079abf5264e982f205c5cb0d079e2f58fddf409f98b26a6329fa803fd51d8578f09f4e04aa8037fd4b8e0fe8c352bb267fe9237458cfff5b11af6f3a656d2d2770993cd2647a1f0909d7b2d1f262927db8d1582f035f2f7cdf17b0e240fc0201e01ff4a0fc97ce6b08a9354de63522959f1bd5930a3907720896b64b6cd7451d49486aa9192a2a8fa0849641aa4dc8722b4cc0878176acb6cb18480e516c7e812949676207da20fe472fb7c50a60327|8a31449273b5dc08f2d28ad2f2ba9538|a0e1ab1282a641c0ad2b63f2c8b85f9a'

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
  
