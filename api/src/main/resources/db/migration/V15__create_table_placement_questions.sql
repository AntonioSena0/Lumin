CREATE TABLE placement_questions(

    id BIGSERIAL PRIMARY KEY,
    level user_language_level NOT NULL,
    question VARCHAR(255) NOT NULL,
    correct_answer VARCHAR(100) NOT NULL,
    options JSONB NOT NULL,
    language_id INTEGER NOT NULL,
    created_at timestamp,

    CONSTRAINT fk_placement_questions_language FOREIGN KEY (language_id) REFERENCES languages(id)
);