ALTER TABLE words ADD CONSTRAINT fk_words_from_languages FOREIGN KEY (from_language_id) REFERENCES languages(id) NOT VALID;
ALTER TABLE words ADD CONSTRAINT fk_words_to_languages FOREIGN KEY (to_language_id) REFERENCES languages(id) NOT VALID;
ALTER TABLE words ADD CONSTRAINT fk_words_categories FOREIGN KEY (category_id) REFERENCES categories(id) NOT VALID;