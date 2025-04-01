CREATE TABLE "Word" (
    word_id UUID PRIMARY KEY,
    word_text VARCHAR(255) NOT NULL,
    translation VARCHAR(255) NOT NULL,
    definition TEXT,
    example_sentence TEXT,
    image_url VARCHAR(255),
    audio_file_url VARCHAR(255),
    folder_id UUID NOT NULL,
    user_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    mastery_level INT,
    last_reviewed TIMESTAMP,
    is_from_recognition BOOLEAN DEFAULT false,
    CONSTRAINT fk_folder FOREIGN KEY (folder_id) REFERENCES "Folder"(folder_id) ON DELETE CASCADE,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES "User"(user_id) ON DELETE CASCADE

);