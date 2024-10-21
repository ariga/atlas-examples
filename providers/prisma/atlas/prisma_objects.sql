-- Create "echo" function
CREATE FUNCTION "echo" (text) RETURNS text LANGUAGE sql AS $$ SELECT $1; $$;

-- Create "echo" procedure
CREATE PROCEDURE echo_p(IN input_text text, OUT output_text text) 
LANGUAGE plpgsql AS $$
BEGIN
    output_text := input_text;
END;
$$;