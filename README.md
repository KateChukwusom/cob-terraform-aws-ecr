# REUSABLE ECR Module

A reusable Terraform module for creating AWS ECR container repositories, each with image scanning, encryption and a lifecycle policy, driven entirely by variables.

## Design principles

- Repository names come from your own keys, prefixed with `team-environment`.
- **Secure by default.** Immutable tags, scan on push and encryption are on unless you turn them off.
- **Everything optional has a default.** `api = {}` is a complete, valid repository definition.
- **Validation catches mistakes before `apply`.** Uppercase team names, invalid repository names and tag-mutability values fail at `plan`.

## Variables

| Variable | Type | Default | Description |
| --- | --- | --- | --- |
| `team` | string | required | Lowercase team name, used in names and tags (max 20 characters) |
| `environment` | string | required | `"dev"` or `"prod"` |
| `ecr_repositories` | map(object) | `{}` | Repositories keyed by short name |

### `ecr_repositories` settings (all optional)

| Setting | Default | Description |
| --- | --- | --- |
| `image_tag_mutability` | `"IMMUTABLE"` | `"MUTABLE"` or `"IMMUTABLE"` |
| `scan_on_push` | `true` | Scan images for vulnerabilities on push |
| `force_delete` | `false` | Allow deleting a repository that still has images |
| `max_image_count` | `30` | Images to keep. `0` disables the lifecycle policy |
| `kms_key_arn` | `null` | Use this KMS key instead of AES256 encryption |

```hcl
ecr_repositories = {
  api = {}
  web = { image_tag_mutability = "MUTABLE", max_image_count = 10 }
}
```

## Tagging tip

With the default `IMMUTABLE` tags a tag can never be overwritten, so tag every image with something unique, such as the commit SHA, and never push `latest` twice.

## Outputs

| Output | Description |
| --- | --- |
| `repository_urls` | Map of key, repository URL (use as the image in ECS) |
| `repository_arns` | Map of key, repository ARN |
| `repository_names` | Map of key, full repository name |

## Using this module

```hcl
module "ecr" {
  source = "git::https://github.com/KateChukwusom/AWSTerraform_Modules.git//modules/ECR?ref=v1.0.0"

  team             = "platform"
  environment      = "dev"
  ecr_repositories = var.ecr_repositories
}
```

## Requirements

Terraform >= 1.9.0 and the AWS provider ~> 6.0.
