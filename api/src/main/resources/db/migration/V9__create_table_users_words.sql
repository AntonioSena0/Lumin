CREATE TYPE word_domain_level AS ENUM('DISCOVERED', 'PRACTICING', 'FAMILIAR');

CREATE TABLE users_words (

    user_id BIGINT NOT NULL,
    word_id BIGINT NOT NULL,
    PRIMARY KEY(user_id, word_id),
    last_practiced timestamp,
    is_saved BOOLEAN NOT NULL DEFAULT false,
    correct_answers BIGINT NOT NULL DEFAULT 0,
    incorrect_answers BIGINT NOT NULL DEFAULT 0,
    level word_domain_level NOT NULL DEFAULT 'DISCOVERED',
    created_at timestamp

);