variable "database_url" {
  type        = string
  default     = getenv("DATABASE_URL")
  description = "URL to the target database to apply changes"
}

env "dev" {
  url = var.database_url
  dev = "docker://postgres/15/dev?search_path=public"
  schema {
    src = "file://schema.sql"
    repo {
      name = "circleci-atlas-action-declarative-demo"
    }
  }
  diff {
    concurrent_index {
      add  = true
      drop = true
    }
  }
}