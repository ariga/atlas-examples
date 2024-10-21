-- Create "User" table
CREATE TABLE "User" ("id" serial NOT NULL, "name" text NOT NULL, "email" text NOT NULL, PRIMARY KEY ("id"));
-- Create index "User_email_key" to table: "User"
CREATE UNIQUE INDEX "User_email_key" ON "User" ("email");
