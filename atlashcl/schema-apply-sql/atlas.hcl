docker "postgres" "dev" {
  image  = "postgres:15"
  schema = "public"
  // Unlike the HCL example, this example uses a file()
  // function to read the contents of the baseline file.
  baseline = file("baseline.sql")
}

env "local" {
  src = "file://schema.sql"
  dev = docker.postgres.dev.url
  url = "postgres://postgres:pass@localhost:5435/test?search_path=public&sslmode=disable"
}
