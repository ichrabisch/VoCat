CREATE OR REPLACE PROCEDURE sp_CreateFolder(
    p_folder_id uuid,
    p_folder_name VARCHAR,
    p_user_id uuid
) 
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO "Folder"
    (
        folder_id,
        name,
        user_id
    )
    VALUES
    (
        p_folder_id,
        p_folder_name,
        p_user_id
    );
    COMMIT;
END;
$$;