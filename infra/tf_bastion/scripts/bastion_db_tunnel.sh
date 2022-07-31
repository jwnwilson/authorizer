#! /bin/bash

INSTANCE_ID=`terraform output -raw bastion_id`
aws ssm start-session --target ${INSTANCE_ID} \
    --document-name AWS-StartPortForwardingSession \
    --parameters '{"portNumber":["5432"],"localPortNumber":["5432"]}'