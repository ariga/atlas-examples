data "external_schema" "prisma" {
    program = [ 
      "npx",
      "prisma",
      "migrate",
      "diff",
      "--from-empty",
      "--to-schema-datamodel",
      "prisma/schema.prisma",
      "--script"
    ]
}

data "composite_schema" "prisma-objects" {
  schema "public" {
    url = data.external_schema.prisma.url
  }
  schema "public" {
    url = "file://atlas/prisma_objects.sql"
  }
}

env "local" {
  src = data.composite_schema.prisma-objects.url
  dev = "docker://postgres/16/dev?search_path=public"
  migration {
    dir = "file://atlas/migrations"
    exclude = ["_prisma_migrations"]
  }
}