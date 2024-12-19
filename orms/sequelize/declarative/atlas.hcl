data "external_schema" "sequelize" {
  program = [
    "npx",
    "@ariga/atlas-provider-sequelize",
    "load",
    "--path", "./models",
    "--dialect", "postgres",
  ]
}

env {
  name = atlas.env
  dev = "docker://postgres/16/dev?search_path=public"
  schema {
    src = data.external_schema.sequelize.url
    repo {
      name = "sequelize-declarative-demo"
    }
  }
}