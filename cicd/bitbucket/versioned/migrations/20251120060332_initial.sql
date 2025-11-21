-- Create "users" table
CREATE TABLE "users" (
  "id" bigserial NOT NULL,
  "name" text NOT NULL,
  "active" boolean NOT NULL,
  "address" text NOT NULL,
  "nickname" text NOT NULL,
  "nickname2" text NOT NULL,
  "nickname3" text NOT NULL,
  PRIMARY KEY ("id")
);
-- Create index "users_active" to table: "users"
CREATE INDEX "users_active" ON "users" ("active");
