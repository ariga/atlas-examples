### Example for declarative migrations using SQL schema

1\. Log in using `atlas login`.

2\. Run `atlas schema apply --env local` to apply the schema to a local database. The planned changes are as follows:

```sql
-- Planned Changes:
-- Create "users" table
CREATE TABLE "users" (
  "id" uuid NOT NULL DEFAULT auth.random_user_id(),
  "uuid" uuid NOT NULL DEFAULT extensions.uuid_generate_v4()
);
-- Create "auth_users" view
CREATE VIEW "auth_users" (
  "id"
) AS SELECT users.id
   FROM (users
     JOIN auth.users users_1 USING (id));
```

3\. Running `atlas schema apply --env local` again will not apply any changes because the schema is synced with the database.

```text
$ atlas schema apply --env local
Schema is synced, no changes to be made
```
