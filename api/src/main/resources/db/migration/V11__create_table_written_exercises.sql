CREATE TYPE exercise_type AS ENUM('FILL_IN', 'TRANSLATE', 'MULTIPLE_CHOICE', 'REWRITE');

CREATE TABLE written_exercises(

    id BIGINT PRIMARY KEY REFERENCES exercises(id),
    sub_type exercise_type NOT NULL,
    correct_answer varchar(255) NOT NULL,
    options JSONB

);