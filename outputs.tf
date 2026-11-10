# outputs.tf

output "repository_urls" {
  description = "URLs of the repositories created, keyed by repository key. Use these as the image source in ECS"
  value       = { for key, repo in aws_ecr_repository.cob_repository : key => repo.repository_url }
}

output "repository_arns" {
  description = "ARNs of the repositories created, keyed by repository key"
  value       = { for key, repo in aws_ecr_repository.cob_repository : key => repo.arn }
}

output "repository_names" {
  description = "Full names of the repositories created, keyed by repository key"
  value       = { for key, repo in aws_ecr_repository.cob_repository : key => repo.name }
}