variable "database_url" {
  type        = string
  default     = getenv("DATABASE_URL")
  description = "URL to the target database to apply changes"
}

env "dev" {
  src = "file://schema.sql"
  url = var.database_url
  dev = "docker://postgres/15/dev?search_path=public"
  migration {
    dir = "file://migrations"
  }
  diff {
    concurrent_index {
      add  = true
      drop = true
    }
  }
}