CREATE TABLE exercises(

    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    instruction VARCHAR(255) NOT NULL,
    prompt TEXT NOT NULL,
    created_at timestamp,
    language_id INTEGER NOT NULL,
    word_id BIGINT NOT NULL,
    session_id BIGINT

);