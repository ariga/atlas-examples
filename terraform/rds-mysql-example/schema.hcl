// Create a new database named "hello"
schema "hello" {}

// Create a table named "users".
table "users" {
  schema = schema.hello
  column "id" {
    type = int
  }
  column "name" {
    type = varchar(255)
  }
}