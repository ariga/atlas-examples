schema "hello" {}

table "users" {
  schema = schema.hello
  column "id" {
    type = int
  }
  column "name" {
    type = varchar(255)
  }
}