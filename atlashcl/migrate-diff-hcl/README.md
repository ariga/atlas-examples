### Example for declarative migrations using HCL schema

1\. Log in using `atlas login`.

2\. Run `atlas migrate diff --env local`. Note that Atlas creates a new migration file with `users` and `auth_users` defined. 
However, resources defined in the baseline file/schema are not included in the diff.

```sql
-- Create "users" table
CREATE TABLE "users" ("id" uuid NOT NULL DEFAULT auth.random_user_id());
-- Create "auth_users" view
CREATE VIEW "auth_users" ("id") AS SELECT users.id
   FROM (users
     JOIN auth.users users_1 USING (id));
```

3\. Running `atlas migrate diff --env local` again will not create a new migration file because the diff is empty.

Note that in the above example, migration files were generated without a schema qualifier. This is because we defined
the `docker.postgres.dev` dev-database to operate on a single schema (`public`). Thus, the generated migration files
can potentially be applied to any schema.

To generate migration files with a schema qualifier, we need to remove the schema argument from the `docker.postgres.dev`
dev-database definition. The `schema "public" {}` block in our `schema.pg.sql` file controls the name of the schema
that Atlas will use in `migrate diff`.

```diff
docker "postgres" "dev" {
  image  = "postgres:15"
- schema = "public"
  ...
}
```

Let's delete the migrations directory and run the `atlas migrate diff --env local` command again:

```sql
-- Create "users" table
CREATE TABLE "public"."users" ("id" uuid NOT NULL DEFAULT auth.random_user_id());
-- Create "auth_users" view
CREATE VIEW "public"."auth_users" ("id") AS SELECT users.id
   FROM (users
     JOIN auth.users users_1 USING (id));
```
