# Prisma Example

This example illustrate how to use Atlas as a migration engine for Prisma.

## Prerequisites

- [Prisma CLI](https://www.prisma.io/docs/getting-started/installation)
- [Atlas CLI](https://docs.atlas.mongodb.com/reference/atlas-cli/install/)
- [Docker](https://docs.docker.com/get-docker/)

## Getting Started

1. Clone the repository

```bash
git clone https://github.com/ariga/atlas-examples.git
```

2. Change directory to `providers/prisma`

```bash
cd providers/prisma
```

3. Install dependencies

```bash
npm install
```

4. Start postgres database for applying migrations

```bash
docker run --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:16
```

6. Apply the migrations

```bash
atlas migrate apply --env local --url "postgresql://postgres:postgres@localhost:5432/postgres?search_path=public&sslmode=disable"
```

The expected output should be:

```bash
Migrating to version 20241018072810 (3 migrations in total):

  -- migrating version 20241018044955
    -> CREATE TABLE "User" ("id" serial NOT NULL, "name" text NOT NULL, "email" text NOT NULL, PRIMARY KEY ("id"));
    -> CREATE UNIQUE INDEX "User_email_key" ON "User" ("email");
  -- ok (12.445917ms)

  -- migrating version 20241018071458
    -> CREATE FUNCTION "echo" (text) RETURNS text LANGUAGE sql AS $$ SELECT $1; $$;
  -- ok (5.184292ms)

  -- migrating version 20241018072810
    -> CREATE PROCEDURE "echo_p" ("input_text" text, OUT "output_text" text) LANGUAGE plpgsql AS $$
       BEGIN
           output_text := input_text;
       END;
       $$;
  -- ok (2.246541ms)

  -------------------------
  -- 67.961666ms
  -- 3 migrations
  -- 4 sql statements
```

7. Planning migrations via `schema.prisma`

Edit the `schema.prisma` file to add "Post" model and run the following command to generate the migration plan.

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id    Int    @id @default(autoincrement())
  name  String
  email String @unique
  Post  Post[]
}

model Post {
  id         Int        @id @default(autoincrement())
  createdAt  DateTime   @default(now())
  updatedAt  DateTime   @updatedAt
  title      String
  published  Boolean    @default(false)
  author     User       @relation(fields: [authorId], references: [id])
  authorId   Int
}
```

Then run:
```bash
atlas migrate diff --env local
```

You will see a new migration plan that includes the new model "Post" in `atlas/migrations/`.

8. Planning migrations via `extended` schema

Edit `atlas/prisma_objects.sql` to add new a new trigger and run the following command to generate the migration plan.

```sql
-- Create "echo" function

CREATE FUNCTION echo(text) RETURNS text LANGUAGE sql AS $$ SELECT $1; $$;

-- Create "echo" procedure
CREATE PROCEDURE echo_p(IN input_text text, OUT output_text text) 
LANGUAGE plpgsql AS $$
BEGIN
    output_text := input_text;
END;
$$;

-- Create a function that sets the "updated_at" column to the current time
CREATE FUNCTION set_updated_at_to_now() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER updated_at_trigger
AFTER INSERT ON "Post"
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_to_now();
```

Then run:
```bash
atlas migrate diff --env local
```

You will see a new migration plan that includes the new trigger in `atlas/migrations/` folder.