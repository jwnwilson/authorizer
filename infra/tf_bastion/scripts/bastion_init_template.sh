#! /bin/bash
# Install port forwarding
yum install socat -y
# Run port forward as background task
socat tcp-listen:5432,reuseaddr,fork tcp:{{DB_URL}}:5432 &