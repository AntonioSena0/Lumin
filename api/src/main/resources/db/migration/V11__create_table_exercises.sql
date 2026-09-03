CREATE TYPE exercise_correct AS ENUM('UNEVALUATED', 'CORRECT', 'INCORRECT');

CREATE TABLE exercises(
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    instruction VARCHAR(255) NOT NULL,
    prompt TEXT NOT NULL,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    correct exercise_correct DEFAULT 'UNEVALUATED',
    order_index INTEGER NOT NULL DEFAULT 0,
    language_id INTEGER NOT NULL,
    word_id BIGINT NOT NULL,
    session_id BIGINT,
    created_at timestamp,
    CONSTRAINT fk_languages_exercises FOREIGN KEY (language_id) REFERENCES languages(id),
    CONSTRAINT fk_words_exercises FOREIGN KEY (word_id) REFERENCES words(id),
    CONSTRAINT fk_study_sessions_exercises FOREIGN KEY (session_id) REFERENCES study_sessions(id)
);
