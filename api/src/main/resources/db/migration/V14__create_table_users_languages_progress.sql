CREATE TYPE user_language_level AS ENUM('N1', 'N2', 'N3');

CREATE TABLE users_languages_progress(
    user_id BIGINT NOT NULL,
    language_id INTEGER NOT NULL,
    level user_language_level NOT NULL DEFAULT 'N1',
    xp BIGINT NOT NULL DEFAULT 0,
    total_sessions BIGINT NOT NULL DEFAULT 0,
    total_correct_answers BIGINT NOT NULL DEFAULT 0,
    total_incorrect_answers BIGINT NOT NULL DEFAULT 0,
    last_practiced timestamp,
    created_at timestamp,
    updated_at timestamp,
    PRIMARY KEY(user_id, language_id),
    CONSTRAINT fk_users_languages_progress_users FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_users_languages_progress_languages FOREIGN KEY(language_id) REFERENCES languages(id)
);
