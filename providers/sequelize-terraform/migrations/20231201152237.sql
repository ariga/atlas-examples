-- Create "Users" table
CREATE TABLE "public"."Users" (
  "id" serial NOT NULL,
  "name" character varying(255) NOT NULL,
  "email" character varying(255) NOT NULL,
  "hobby" character varying(255) NOT NULL,
  "createdAt" timestamptz NOT NULL,
  "updatedAt" timestamptz NOT NULL,
  PRIMARY KEY ("id")
);
-- Create "Tasks" table
CREATE TABLE "public"."Tasks" (
  "id" serial NOT NULL,
  "complete" boolean NULL DEFAULT false,
  "createdAt" timestamptz NOT NULL,
  "updatedAt" timestamptz NOT NULL,
  "userID" integer NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "Tasks_userID_fkey" FOREIGN KEY ("userID") REFERENCES "public"."Users" ("id") ON UPDATE CASCADE ON DELETE NO ACTION
);
