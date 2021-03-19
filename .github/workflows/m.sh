#!/bin/bash
 
set -ex
 
PROJECT_ID='332'
API_KEY='p1VhOZjaqkNtrUikuncEauq3aKFTbFh1BF5L9J0i'
CLIENT_ID='4caf6bf2599d0428191f4a2ab0cc745a'
SCOPES=['"ViewTestResults"','"ViewAutomationHistory"']
API_URL='https://7iggpnqgq9.execute-api.us-east-2.amazonaws.com/udbodh/api'
INTEGRATION_JWT_TOKEN='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwcm9qZWN0X2lkIjozMzIsImFwaV9rZXlfaWQiOjI0ODAsIm5hbWUiOiIiLCJkZXNjcmlwdGlvbiI6IiIsImljb24iOiIiLCJpbnRlZ3JhdGlvbl9uYW1lIjoiR2l0aHViIiwib3B0aW9ucyI6e30sImlhdCI6MTYxNjE0NDgxNn0.6dUIS6GpJBhTfdIJz4Fxmq68FIbUDxfuFq3-xmNK0bQ'
INTEGRATIONS_API_URL='http://f1fadec276a6.ngrok.io'
 
sudo apt-get update -y
sudo apt-get install -y jq
 
#Trigger test run
TEST_RUN_ID="$( \
  curl -X POST -G ${INTEGRATIONS_API_URL}/api/integrations/github/${PROJECT_ID}/events \
    -d 'token='$INTEGRATION_JWT_TOKEN''\
    -d 'projectId='$PROJECT_ID''\
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

