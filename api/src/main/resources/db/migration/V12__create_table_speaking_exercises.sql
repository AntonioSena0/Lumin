CREATE TABLE speaking_exercises(

    id BIGINT PRIMARY KEY REFERENCES exercises(id),
    required_words JSONB NOT NULL

);