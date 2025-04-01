CREATE OR REPLACE FUNCTION public.fn_selectwordsbyfolderid(p_folder_id uuid)
 RETURNS TABLE(
    word_id uuid, 
    word_text varchar(255), 
    translation varchar(255), 
    definition text, 
    example_sentence text, 
    image_url varchar(255), 
    audio_file_url varchar(255), 
    folder_id uuid, 
    user_id uuid, 
    created_at timestamp, 
    updated_at timestamp, 
    mastery_level integer, 
    last_reviewed timestamp, 
    is_from_recognition boolean
 )
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        w.word_id,
        w.word_text,
        w.translation,
        w.definition,
        w.example_sentence,
        w.image_url,
        w.audio_file_url,
        w.folder_id,
        w.user_id,
        w.created_at,
        w.updated_at,
        w.mastery_level,
        w.last_reviewed,
        w.is_from_recognition
    FROM "Word" w
    WHERE w.folder_id = p_folder_id;
END;
$function$;