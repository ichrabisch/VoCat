CREATE OR REPLACE PROCEDURE sp_UpdateFolder(
    p_folder_id uuid,
    p_name VARCHAR = NULL,
    p_parent_folder_id uuid = NULL,
    p_user_id uuid = NULL,
    p_created_at TIMESTAMP WITHOUT TIME ZONE = NULL,
    p_updated_at TIMESTAMP WITHOUT TIME ZONE = NULL
) 
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE "Folder"
    SET
        name = COALESCE(p_name,name),
        parent_folder_id =  COALESCE(p_parent_folder_id, parent_folder_id),
        created_at = created_at,
        updated_at = CURRENT_TIMESTAMP
    WHERE folder_id = p_folder_id;
END;
$$;