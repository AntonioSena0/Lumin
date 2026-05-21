CREATE TABLE exercises(

    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    instruction VARCHAR(255) NOT NULL,
    prompt TEXT NOT NULL,
    last_practiced timestamp,
    created_at timestamp,
    user_id BIGINT NOT NULL,
    language_id INTEGER NOT NULL,
    word_id BIGINT NOT NULL

);