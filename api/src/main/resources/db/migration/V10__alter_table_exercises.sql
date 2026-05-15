ALTER TABLE exercises ADD CONSTRAINT fk_users_exercises FOREIGN KEY (user_id) REFERENCES users(id) NOT VALID;
ALTER TABLE exercises ADD CONSTRAINT fk_languages_exercises FOREIGN KEY (language_id) REFERENCES languages(id) NOT VALID;
ALTER TABLE exercises ADD CONSTRAINT fk_words_exercises FOREIGN KEY (word_id) REFERENCES words(id) NOT VALID;