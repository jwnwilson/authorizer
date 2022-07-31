#! /bin/bash

INSTANCE_ID=`terraform output -raw bastion_id`
aws ssm start-session --target ${INSTANCE_ID}