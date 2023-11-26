schema "public" {}

table "users" {
  schema = schema.public
  column "id" {
    type = uuid
    default = sql("auth.random_user_id()")
  }
}

view "auth_users" {
  schema = schema.public
  column "id" {
    type = int
  }
  // language=postgresql
  as = <<SQL
   SELECT id FROM users JOIN auth.users USING (id)
  SQL
  depends_on = [
    table.users,
  ]
}
