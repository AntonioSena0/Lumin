CREATE TABLE speaking_exercises(
    id BIGINT PRIMARY KEY,
    required_words JSONB NOT NULL,

    CONSTRAINT fk_speaking_exercises FOREIGN KEY (id) REFERENCES exercises(id) ON DELETE CASCADE
);
