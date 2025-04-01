CREATE OR REPLACE PROCEDURE sp_CreateWord(
    p_word_id uuid,
    p_word_text VARCHAR,
    p_translation VARCHAR,
    p_folder_id uuid,
    p_user_id uuid,
    p_mastery_level INTEGER
) 
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO "Word"
    (
        word_id,
        word_text,
        translation,
        folder_id,
        user_id,
        mastery_level
    )
    VALUES
    (
        p_word_id,
        p_word_text,
        p_translation,
        p_folder_id,
        p_user_id,
        p_mastery_level
    );
    COMMIT;
END;
$$;