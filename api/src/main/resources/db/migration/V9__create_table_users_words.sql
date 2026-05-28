CREATE TABLE users_words (

    user_id BIGINT NOT NULL,
    word_id BIGINT NOT NULL,
    PRIMARY KEY(user_id, word_id),
    last_practiced timestamp,
    created_at timestamp

);