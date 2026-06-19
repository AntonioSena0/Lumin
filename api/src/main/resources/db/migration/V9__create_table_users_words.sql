CREATE TYPE word_domain_level AS ENUM('BASIC', 'INTERMEDIATE', 'ADVANCED');

CREATE TABLE users_words (

    user_id BIGINT NOT NULL,
    word_id BIGINT NOT NULL,
    PRIMARY KEY(user_id, word_id),
    last_practiced timestamp,
    correct_answers BIGINT NOT NULL,
    incorrect_answers BIGINT NOT NULL,
    level word_domain_level NOT NULL,
    created_at timestamp

);