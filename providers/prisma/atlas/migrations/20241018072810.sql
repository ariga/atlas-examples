-- Create "echo_p" procedure
CREATE PROCEDURE "echo_p" ("input_text" text, OUT "output_text" text) LANGUAGE plpgsql AS $$
BEGIN
    output_text := input_text;
END;
$$;
