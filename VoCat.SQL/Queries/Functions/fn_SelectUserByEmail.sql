CREATE OR REPLACE FUNCTION public.fn_selectuserbyemail(p_email character varying)
 RETURNS TABLE(user_id uuid, user_name character varying, email character varying, password_hash character varying, created_at timestamp without time zone, last_login timestamp without time zone, preferred_language character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        u.user_id,
        u.user_name,
        u.email,
        u.password_hash,
        u.created_at,
        u.last_login,
        u.preferred_language
    FROM "User" u
    WHERE u.email = p_email;
END;
$function$
