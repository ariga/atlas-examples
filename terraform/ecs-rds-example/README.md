### Terraform + ECS (Fargate) + RDS + Atlas Cloud Example

This example contains  a Terraform configuration to providion an RDS MySQL database and a backend application 
running on AWS ECS (Fargate) which uses Atlas Cloud to manage its database migrations.

One of it's main advantages is that it avoids needing to build a custom container for database migrations
as those are pushed to Atlas Cloud by your delivery pipeline. 

## Pre-requisites

* An AWS account
* An Atlas Cloud account (sign up [here](https://auth.atlasgo.cloud/signup))
* An Atlas Cloud [Bot Token](https://atlasgo.io/cloud/bots).
* A migration directory pushed to Atlas Cloud. See [here](https://atlasgo.io/versioned/intro#pushing-migrations-to-atlas) for more information.

This setup assumes that you have an existing Atlas Cloud account and have created a 


## Setup

Create a secret that will contain your Atlas Cloud token:

```bash
aws secretsmanager create-secret \
  --name atlas-cloud-token \
  --secret-string "aci_<your_token_here>"
```

Initialize the Terraform configuration:

```bash
terraform init
```

## Deploying

To deploy the infrastructure, run:

```bash
terraform apply -var dir="<your_migration_dir>" -var tag="<revision_tag>"
```





