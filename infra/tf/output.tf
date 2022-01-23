output "vpc_id" {
  value = module.vpc.vpc_id
}

output "db_url" {
  value = module.db.db_instance_address
}