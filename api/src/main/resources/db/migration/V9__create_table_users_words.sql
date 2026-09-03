CREATE TYPE word_domain_level AS ENUM('DISCOVERED', 'PRACTICING', 'FAMILIAR');

CREATE TABLE users_words (
    user_id BIGINT NOT NULL,
    word_id BIGINT NOT NULL,
    last_practiced timestamp,
    is_saved BOOLEAN NOT NULL DEFAULT false,
    correct_answers BIGINT NOT NULL DEFAULT 0,
    incorrect_answers BIGINT NOT NULL DEFAULT 0,
    level word_domain_level NOT NULL DEFAULT 'DISCOVERED',
    created_at timestamp,
    PRIMARY KEY(user_id, word_id),
    CONSTRAINT fk_users_words_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_users_words_words FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
);
