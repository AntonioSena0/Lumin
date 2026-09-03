CREATE TABLE words (
    id BIGSERIAL PRIMARY KEY,
    original VARCHAR(100) NOT NULL,
    translated VARCHAR(100) NOT NULL,
    description VARCHAR(200) NOT NULL,
    from_language_id INTEGER NOT NULL,
    to_language_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    created_at timestamp,
    updated_at timestamp,
    CONSTRAINT fk_words_from_languages FOREIGN KEY (from_language_id) REFERENCES languages(id),
    CONSTRAINT fk_words_to_languages FOREIGN KEY (to_language_id) REFERENCES languages(id),
    CONSTRAINT fk_words_categories FOREIGN KEY (category_id) REFERENCES categories(id),
    CONSTRAINT unique_words UNIQUE (original, translated, from_language_id, to_language_id, category_id)
);
