CREATE SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA "extensions";
CREATE SCHEMA "auth";
CREATE TABLE "auth"."users" ("id" uuid NOT NULL DEFAULT extensions.uuid_generate_v4(), PRIMARY KEY ("id"));
CREATE FUNCTION "auth"."random_user_id"()
RETURNS uuid
AS $$
    SELECT "auth"."users"."id"
    FROM "auth"."users"
    ORDER BY random()
    LIMIT 1
$$ LANGUAGE SQL;