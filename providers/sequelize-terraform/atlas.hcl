data "external_schema" "sequelize" {
    program = [
        "npx",
        "@ariga/atlas-provider-sequelize",
        "load",
        "--path", "./model",
        "--dialect", "mysql", // mariadb | postgres | sqlite | mssql
    ]
}

env "sequelize" {
    src = data.external_schema.sequelize.url
    dev = "docker://mysql/8/dev"
    migration {
        dir = "file://migrations"
    }
    format {
        migrate {
            diff = "{{ sql . \"  \" }}"
        }
    }
}
