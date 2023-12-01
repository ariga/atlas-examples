data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "db" {
  name = "db-url"
}

data "aws_secretsmanager_secret_version" "db_url" {
  secret_id = data.aws_secretsmanager_secret.db.id
}

data "aws_secretsmanager_secret" "atlas-cloud" {
  name = "atlas-cloud-token"
}

data "aws_secretsmanager_secret_version" "atlascloud_token" {
  secret_id = data.aws_secretsmanager_secret.atlas-cloud.id
}

provider "atlas" {
  cloud {
    token = data.aws_secretsmanager_secret_version.atlascloud_token.secret_string
  }
}

resource "atlas_migration" "app" {
  url = data.aws_secretsmanager_secret_version.db_url.secret_string
  remote_dir {
    name = "sequelize"
    tag  = var.tag
  }
}

output "migration_revision" {
  value = atlas_migration.app.version
}