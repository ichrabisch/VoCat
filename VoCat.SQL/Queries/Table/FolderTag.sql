CREATE TABLE "FolderTag" (
    folder_id UUID NOT NULL,
    tag_id UUID NOT NULL,
    CONSTRAINT fk_folder FOREIGN KEY (folder_id) REFERENCES "Folder"(folder_id) ON DELETE CASCADE,
    CONSTRAINT fk_tag FOREIGN KEY (tag_id) REFERENCES "Tag"(tag_id) ON DELETE CASCADE,
    PRIMARY KEY (folder_id, tag_id)

);
