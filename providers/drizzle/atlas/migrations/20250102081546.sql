-- Create "users" table
CREATE TABLE "users" ("id" integer NOT NULL GENERATED ALWAYS AS IDENTITY, "name" character varying(255) NOT NULL, "age" integer NOT NULL, "email" character varying(255) NOT NULL, PRIMARY KEY ("id"), CONSTRAINT "users_email_unique" UNIQUE ("email"));
