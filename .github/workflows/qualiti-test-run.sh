#!/bin/bash
 
set -ex
 
PROJECT_ID='332'
API_KEY='8reFC8xx0K3JcHfRJ8FgytSl2s16rNj2M0FKehIb'
CLIENT_ID='19a0fe96a2166756171809975eb9b8ec'
SCOPES=['"ViewTestResults"','"ViewAutomationHistory"']
API_URL='https://7iggpnqgq9.execute-api.us-east-2.amazonaws.com/udbodh/api'
INTEGRATION_JWT_TOKEN='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwcm9qZWN0X2lkIjozMzIsImdpdGxhYl9wcm9qZWN0X2lkIjoyNDI0NDc1OCwiZ2l0bGFiX3Byb2plY3RfYWNjZXNzX3Rva2VuIjoiZkc0eE5Id2RXTk56UEZ5WEhYcHciLCJpYXQiOjE2MTQ5MjkyMDd9.a8svghZY4NPJbPqimA6eOQZZw8jruj3zRS0HgLauYes'
INTEGRATIONS_API_URL='http://4050c6d12ba3.ngrok.io'
 
apt-get update -y
apt-get install -y jq
 
#Trigger test run
TEST_RUN_ID="$( \
  curl -X POST -G ${INTEGRATIONS_API_URL}/api/integrations/github/${PROJECT_ID}/events \
    -d 'token='$INTEGRATION_JWT_TOKEN''\
    -d 'triggerType=Deploy'\
  | jq -r '.test_run_id')"
 
AUTHORIZATION_TOKEN="$( \
  curl -X POST -G ${API_URL}/auth/token \
  -H 'x-api-key: '${API_KEY}'' \
  -H 'client_id: '${CLIENT_ID}'' \
  -H 'scopes: '${SCOPES}'' \
  | jq -r '.token')"
 
# Wait until the test run has finished
while : ; do
   RESULT="$( \
   curl -X GET ${API_URL}/automation-history?project_id=${PROJECT_ID}\&test_run_id=${TEST_RUN_ID} \
   -H 'token: Bearer '$AUTHORIZATION_TOKEN'' \
   -H 'x-api-key: '${API_KEY}'' \
  | jq -r '.[0].finished')"
  if [ "$RESULT" != null ]; then
    break;
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
