CREATE OR REPLACE PROCEDURE sp_UpdateWord(
    p_word_id uuid,
    p_word_text VARCHAR = NULL,
    p_translation VARCHAR = NULL,
    p_definition VARCHAR = NULL,
    p_example_sentence VARCHAR = NULL, 
    p_image_url VARCHAR = NULL,
    p_audio_file_url VARCHAR = NULL,
    p_folder_id uuid = NULL,
    p_user_id uuid = NULL,
    p_created_at TIMESTAMP WITHOUT TIME ZONE = NULL,
    p_updated_at TIMESTAMP WITHOUT TIME ZONE = NULL,
    p_mastery_level INTEGER = 0,
    p_last_reviewed TIMESTAMP WITHOUT TIME ZONE = NULL,
    p_is_from_recognition BOOLEAN = NULL
) 
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE "Word"
    SET
        word_text = COALESCE(p_word_text, word_text),
        translation = COALESCE(p_translation, translation),
        definition = COALESCE(p_definition, definition),
        example_sentence = COALESCE(p_example_sentence, example_sentence),
        image_url = COALESCE(p_image_url, image_url),
        audio_file_url = COALESCE(p_audio_file_url, audio_file_url),
        folder_id = COALESCE(p_folder_id, folder_id),
        created_at = created_at,
        updated_at = CURRENT_TIMESTAMP,
        mastery_level = CASE WHEN p_mastery_level = 0 THEN mastery_level ELSE p_mastery_level END,
        last_reviewed = COALESCE(p_last_reviewed, last_reviewed),
        is_from_recognition = COALESCE(p_is_from_recognition, is_from_recognition)
    WHERE word_id = p_word_id;
END;
$$;