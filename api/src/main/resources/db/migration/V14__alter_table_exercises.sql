ALTER TABLE exercises ADD CONSTRAINT fk_languages_exercises FOREIGN KEY (language_id) REFERENCES languages(id) NOT VALID;
ALTER TABLE exercises ADD CONSTRAINT fk_words_exercises FOREIGN KEY (word_id) REFERENCES words(id) NOT VALID;
ALTER TABLE exercises ADD CONSTRAINT fk_study_sessions_exercises FOREIGN KEY (session_id) REFERENCES study_sessions(id) NOT VALID;