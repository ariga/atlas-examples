# sequelize-terraform

e2e sequelize schema management 

### Desired state

The desired state for this application is defined as a [Sequelize](https://sequelize.org/) schema definition which 
resides in the [`model`](./model) directory.

The desired state is loaded into the `atlas.hcl` file using an `external_schema` data source:

```hcl
data "external_schema" "sequelize" {
    program = [
        "npx",
        "@ariga/atlas-provider-sequelize",
        "load",
        "--path", "./model",
        "--dialect", "mysql", // mariadb | postgres | sqlite | mssql
    ]
}
```

#### Planning new migrations

1. Make a change to the desired state in the [`model`](./model) directory.
2. Run `atlas migrate diff --env sequelize` to see the migration plan.

### Continuous integration

CI is set up using a [GitHub Actions Workflow](./.github/workflows/providers-sequelize-terraform.yml).
Whenever you make a change to your migration directory, the workflow will use the `atlas-action/migrate/lint`
action to check that the migrations are valid and safe.

#### Verifying changes locally

You can run the same checks locally using the following command:

```bash
atlas migrate lint --env sequelize --latest 1
```

The `--latest 1` flag tells Atlas to check the latest migration only. To learn more about 
the `atlas migrate lint` command, see the [Atlas CLI reference](https://atlasgo.io/cli-reference#atlas-migrate-lint).

### Continuous Delivery

The [GitHub Actions Workflow](./.github/workflows/providers-sequelize-terraform.yml) in this repository
will push the migration directory to Atlas Cloud and tag it with the current Git commit SHA whenever
a change is merged to the `master` branch.

### Deployment using Terraform

The [Terraform configuration](./terraform) in this repository relies on two secrets pre-configured in you
AWS account:

Save your [Atlas Cloud token](https://atlasgo.io/cloud/bots) as `atlas-cloud-token` in AWS Secrets Manager:

```
aws secretsmanager create-secret \
  --name atlas-cloud-token \
  --secret-string "aci_your_token_here"
```

Save the database URL as `db-url` in AWS Secrets Manager:

```
aws secretsmanager create-secret \
  --name db-url \
  --secret-string "mysql://user:pass@host:port/db"
```

Next, initialize Terraform:

```bash
terraform init
```

Finally, deploy the infrastructure:

```bash
terraform apply -var tag="<latest master commit sha>"
```