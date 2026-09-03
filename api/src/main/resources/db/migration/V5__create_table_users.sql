CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    native_language_id INTEGER NOT NULL,
    to_language_id INTEGER NOT NULL,
    avatar_id INTEGER DEFAULT 1 NOT NULL,
    created_at timestamp,
    updated_at timestamp,
    CONSTRAINT fk_users_languages_native FOREIGN KEY (native_language_id) REFERENCES languages(id),
    CONSTRAINT fk_users_languages_to FOREIGN KEY (to_language_id) REFERENCES languages(id),
    CONSTRAINT fk_users_avatars FOREIGN KEY (avatar_id) REFERENCES avatars(id)
);
