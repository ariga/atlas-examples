docker "postgres" "dev" {
  image  = "postgres:15"
  schema = "public"
  // language=postgresql
  baseline = <<SQL
   -- 1
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
   -- 2
   CREATE SCHEMA "auth";
   -- 3
   CREATE TABLE "auth"."users" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), PRIMARY KEY ("id"));
   -- 4
   CREATE FUNCTION "auth"."random_user_id"()
   RETURNS uuid
   AS $$
       SELECT "auth"."users"."id"
       FROM "auth"."users"
       ORDER BY random()
       LIMIT 1
   $$ LANGUAGE SQL;
  SQL
}

env "local" {
  src = "file://schema.pg.hcl"
  dev = docker.postgres.dev.url
}
