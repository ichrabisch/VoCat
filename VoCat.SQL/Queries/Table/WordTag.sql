CREATE TABLE "WordTag" (
    word_id UUID NOT NULL,
    tag_id UUID NOT NULL,
    CONSTRAINT fk_word FOREIGN KEY (word_id) REFERENCES "Word"(word_id) ON DELETE CASCADE,
    CONSTRAINT fk_tag FOREIGN KEY (tag_id) REFERENCES "Tag"(tag_id) ON DELETE CASCADE,
    PRIMARY KEY (word_id, tag_id)

);