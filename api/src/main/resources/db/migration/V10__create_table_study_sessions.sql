CREATE TYPE study_status AS ENUM('IN_PROGRESS', 'FINISHED');

CREATE TABLE study_sessions(
    id BIGSERIAL PRIMARY KEY,
    current_index INTEGER NOT NULL,
    total_exercises INTEGER NOT NULL,
    score INTEGER,
    status study_status NOT NULL,
    finished_at timestamp,
    user_id BIGINT NOT NULL,
    created_at timestamp,
    updated_at timestamp,
    CONSTRAINT fk_users_study_sessions FOREIGN KEY (user_id) REFERENCES users(id)
);
