#! /bin/bash
DB_URL=authorizer-db-staging.clfqqiusnlbr.eu-west-1.rds.amazonaws.com
# Install port forwarding
yum install socat -y
# Run port forward as background task
socat tcp-listen:5432,reuseaddr,fork tcp:${DB_URL}:5432 &