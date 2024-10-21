-- Create "echo" function
CREATE FUNCTION "echo" (text) RETURNS text LANGUAGE sql AS $$ SELECT $1; $$;
