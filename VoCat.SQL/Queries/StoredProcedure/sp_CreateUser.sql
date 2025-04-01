CREATE OR REPLACE PROCEDURE public.sp_createuser(IN p_user_id uuid, IN p_user_name character varying, IN p_email character varying, IN p_password_hash character varying)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    INSERT INTO "User"(
        user_id, 
        user_name, 
        email, 
        password_hash)
    VALUES(
        p_user_id, 
        p_user_name, 
        p_email, 
        p_password_hash);

    COMMIT;

END;
$procedure$