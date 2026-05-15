CREATE TABLE written_exercises(

    id BIGINT PRIMARY KEY REFERENCES exercises(id),
    correct_answer varchar(255) NOT NULL,
    options JSONB NOT NULL

);