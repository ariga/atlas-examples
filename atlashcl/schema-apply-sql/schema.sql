-- Create "users" table
CREATE TABLE "users" (
  "id" uuid NOT NULL DEFAULT auth.random_user_id(),
  "uuid" uuid NOT NULL DEFAULT extensions.uuid_generate_v4()
);
-- Create "auth_users" view
CREATE VIEW "auth_users" ("id") AS SELECT users.id
   FROM (users
     JOIN auth.users users_1 USING (id));

