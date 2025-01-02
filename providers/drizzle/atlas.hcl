data "external_schema" "drizzle" {
    program = [
      "npx",
      "drizzle-kit",
      "export",
    ]
}

data "composite_schema" "drizzle-objects" {
  schema "public" {
    url = data.external_schema.drizzle.url
  }
  schema "public" {
    url = "file://atlas/drizzle_objects.sql"
  }
}

env "local" {
  dev = "docker://postgres/16/dev?search_path=public"
  schema {
    src = data.composite_schema.drizzle-objects.url
  }
  migration {
    dir = "file://atlas/migrations"
  }
  exclude = ["drizzle"]
}