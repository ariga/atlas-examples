CREATE TABLE "users" (
  "id" bigserial PRIMARY KEY,
  "name" text NOT NULL,
  "active" boolean NOT NULL,
  "address" text NOT NULL,
  "nickname" text NOT NULL,
  "nickname2" text NOT NULL,
  "nickname3" text NOT NULL
);

CREATE INDEX "users_active" ON "users" ("active");