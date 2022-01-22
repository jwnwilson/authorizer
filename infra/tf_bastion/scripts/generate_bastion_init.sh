#! /bin/bash

cp ./scripts/bastion_init_template.sh ./scripts/bastion_init.sh
sed -i 's/{{DB_URL}}/'"${DB_URL}"'/' ./scripts/bastion_init.sh
