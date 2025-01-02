# Drizzle Example

The sample project demonstrates how to use Atlas as a migration engine for Drizzle.

## Prerequisites

- [Atlas CLI](https://atlasgo.io/docs#installation)
- [Docker](https://docs.docker.com/get-docker/)

## How to use

1. Install dependencies

```bash
pnpm add drizzle-orm pg dotenv
pnpm add -D drizzle-kit tsx @types/pg
```


2. Modify the Drizzle schema `schema.ts`.
3. Run Atlas to plan the migration.

```bash
atlas migrate diff --env local
```

A new migration file will be created in the `atlas/migrations` directory.

4. Start the PostgreSQL database for applying migrations

```bash
docker run --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:16
```

5. Apply the migration to target database

```bash
atlas migrate apply --env local --url "postgresql://postgres:postgres@localhost:5432/postgres?sslmode=disable"
```