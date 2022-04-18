#! /bin/bash

set -e
set -x

source $(dirname "$0")/util.sh

# Trigger db migrate lambda function
cd infra/tf

# Get name of lambda to run
LAMBDA_NAME=`terraform output -raw db_migrator_lambda_name`

# Trigger lambda
aws lambda invoke \
    --function-name $LAMBDA_NAME \
    --payload '{}' \
    response.json

# Wait for result of lambda
RESPONSE=`cat response.json`

echo $RESPONSE

STATUS=`jq $RESPONSE .StatusCode`

if [ "$STATUS" != "200" ]; then
    echo "Error calling migrate DB command"
    exit 1
else
    echo "DB migration successful."
fi