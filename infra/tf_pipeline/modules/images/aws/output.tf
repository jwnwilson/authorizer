output "ecr_auth_url" {
    value = aws_ecr_repository.auth_repo.repository_url
}
