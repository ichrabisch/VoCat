CREATE OR REPLACE FUNCTION public.fn_selectallfolders(p_user_id uuid)
 RETURNS TABLE(folder_id uuid, name character varying, parent_folder_id uuid, user_id uuid, created_at timestamp without time zone, updated_at timestamp without time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        f.folder_id,
        f.name,
        f.parent_folder_id,
        f.user_id,
        f.created_at,
        f.updated_at
    FROM "Folder" f
    WHERE f.user_id = p_user_id;
END;
$function$