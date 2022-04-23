.EXPORT_ALL_VARIABLES:

TF_VAR_docker_tag=${docker_tag}
TF_VAR_ecr_api_url=675468650888.dkr.ecr.eu-west-1.amazonaws.com/authorizer
TF_VAR_environment=${environment}
TF_VAR_aws_access_key=${AWS_ACCESS_KEY_ID}
TF_VAR_aws_secret_key=${AWS_SECRET_ACCESS_KEY}
TF_VAR_aws_region=${AWS_DEFAULT_REGION}
TF_VAR_vpc_id=vpc-055676c11fe77915e
DB_URL=authorizer-db-staging.clfqqiusnlbr.eu-west-1.rds.amazonaws.com

init:
	cd tf && terraform init -input=false

plan:
	cd tf && terraform plan -out tfapply

apply:
	cd tf && terraform apply -auto-approve tfapply

refresh:
	cd tf && terraform refresh

outputs:
	cd tf && terraform output -json

destroy:
	cd tf && terraform destroy

pipeline_init:
	cd tf_pipeline && terraform init

pipeline_appy:
	cd tf_pipeline && terraform apply

pipeline_destroy:
	cd tf_pipeline && terraform destroy

bastion_init:
	cd tf_bastion && terraform init

bastion_refresh:
	cd tf_bastion && terraform refresh	

bastion_plan:
	cd tf_bastion && terraform plan

bastion_apply:
	cd tf_bastion && ./scripts/generate_bastion_init.sh
	cd tf_bastion && terraform apply

bastion_destroy:
	cd tf_bastion && terraform destroy

bastion_output:
	cd tf_bastion && terraform refresh && terraform output -raw bastion_id

bastion_ssh:
	cd tf_bastion && ./scripts/bastion_ssh.sh

bastion_db_tunnel:
	cd tf_bastion && ./scripts/bastion_db_tunnel.sh
