data "runtimevar" "atlas-cloud-token" {
  url = "gcpsecretmanager://projects/atlas-gcp-examples/secrets/atlas-cloud-token"
}

atlas {
  cloud {
    token = data.runtimevar.atlas-cloud-token
  }
}

env "local" {
  src = "schema.hcl"
  dev = "sqlite://?mode=memory"
}