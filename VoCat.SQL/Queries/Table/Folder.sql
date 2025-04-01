CREATE TABLE "Folder" (
    folder_id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_folder_id UUID, 
    user_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES "User"(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_parent_folder FOREIGN KEY (parent_folder_id) REFERENCES "Folder"(folder_id) ON DELETE SET NULL

);