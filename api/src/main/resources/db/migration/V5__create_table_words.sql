CREATE TABLE words (

    id BIGSERIAL PRIMARY KEY,
    original VARCHAR(100) NOT NULL,
    translated VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(200),
    created_at timestamp,
    language_id INTEGER

);