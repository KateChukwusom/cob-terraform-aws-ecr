locals {
  # This is the base combination, reused everywhere
  team_environment = "${var.team}-${var.environment}"

  # tags applied to resource blocks that allows tags argument
  resource_tags = {
    Team        = var.team
    Environment = var.environment
  }

  # Only repositories with max_image_count above 0 get a lifecycle policy
  repositories_with_lifecycle = {
    for key, repo in var.ecr_repositories : key => repo if repo.max_image_count > 0
  }
}

#This creates the ECR repositories, as many as needed, the for_each argument loops over the map and creates each one
resource "aws_ecr_repository" "cob_repository" {
  for_each = var.ecr_repositories

  name                 = "${local.team_environment}-${each.key}"
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  encryption_configuration {
    encryption_type = each.value.kms_key_arn == null ? "AES256" : "KMS"
    kms_key         = each.value.kms_key_arn
  }

  tags = local.resource_tags
}

#This creates the lifecycle policy that expires old images so repositories do not grow forever
resource "aws_ecr_lifecycle_policy" "cob_lifecycle" {
  for_each = local.repositories_with_lifecycle

  repository = aws_ecr_repository.cob_repository[each.key].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only the last ${each.value.max_image_count} images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = each.value.max_image_count
      }
      action = { type = "expire" }
    }]
  })
}