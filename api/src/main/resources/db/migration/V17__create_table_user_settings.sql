CREATE TYPE voice_type AS ENUM ('MALE', 'FEMALE');

CREATE TABLE user_settings (
    user_id BIGINT PRIMARY KEY,
    app_language_id INTEGER NOT NULL DEFAULT 1,
    notify_daily BOOLEAN NOT NULL DEFAULT TRUE,
    notify_review BOOLEAN NOT NULL DEFAULT TRUE,
    voice voice_type NOT NULL DEFAULT 'FEMALE',
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_settings_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_settings_languages FOREIGN KEY (app_language_id) REFERENCES languages(id)
);