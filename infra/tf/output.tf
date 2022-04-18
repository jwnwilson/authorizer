output "vpc_id" {
  value = module.vpc.vpc_id
}

output "db_url" {
  value = module.db.db_instance_address
}

output db_migrator_lambda_name {
  value = module.db_migrator.lambda_function_name
}