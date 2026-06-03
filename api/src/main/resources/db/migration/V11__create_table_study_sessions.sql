CREATE TYPE study_status AS ENUM('IN_PROGRESS', 'FINISHED');

CREATE TABLE study_sessions(

    id BIGSERIAL PRIMARY KEY,
    current_index INTEGER NOT NULL,
    total_exercises INTEGER NOT NULL,
    score INTEGER,
    status study_status NOT NULL,
    finished_at timestamp,
    created_at timestamp,
    updated_at timestamp,
    user_id BIGINT NOT NULL

)