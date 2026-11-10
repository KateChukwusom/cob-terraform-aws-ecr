#The name of the team
variable "team" {
  type        = string
  description = "The team that owns the repositories, used in resource names and tags"
  validation {
    condition     = length(var.team) <= 20
    error_message = "team must be 20 characters or fewer"
  }
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.team))
    error_message = "team must be lowercase letters, digits or hyphens only (ECR repository names must be lowercase)"
  }
}

#Deployment environment
variable "environment" {
  type        = string
  description = "Current environment"
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be dev or prod, it must be spelt that way"
  }
}


variable "ecr_repositories" {
  type = map(object({
    image_tag_mutability = optional(string, "IMMUTABLE")
    scan_on_push         = optional(bool, true)
    force_delete         = optional(bool, false)
    max_image_count      = optional(number, 30)
    kms_key_arn          = optional(string)
  }))
  description = "ECR repositories keyed by short name, with their settings"
  default     = {}

  validation {
    condition     = alltrue([for key, repo in var.ecr_repositories : can(regex("^[a-z0-9]+([._-][a-z0-9]+)*$", key))])
    error_message = "Repository keys must be lowercase letters and digits, optionally separated by . _ or -"
  }

  validation {
    condition     = alltrue([for key, repo in var.ecr_repositories : contains(["MUTABLE", "IMMUTABLE"], repo.image_tag_mutability)])
    error_message = "image_tag_mutability must be \"MUTABLE\" or \"IMMUTABLE\"."
  }

  validation {
    condition     = alltrue([for key, repo in var.ecr_repositories : repo.max_image_count >= 0])
    error_message = "max_image_count must be 0 (no lifecycle policy) or higher."
  }
}