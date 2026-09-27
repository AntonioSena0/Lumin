CREATE INDEX IF NOT EXISTS idx_word_original_translated ON words(original, translated);
CREATE INDEX IF NOT EXISTS idx_word_fromlang_original ON words(original, from_language_id);
CREATE INDEX IF NOT EXISTS idx_refresh_user ON refresh_tokens(user_id);

CREATE INDEX IF NOT EXISTS idx_users_words_weak ON users_words(user_id, incorrect_answers);
CREATE INDEX IF NOT EXISTS idx_users_words_practiced ON users_words(user_id, last_practiced);
CREATE INDEX IF NOT EXISTS idx_exercises_session ON exercises(session_id);
CREATE INDEX IF NOT EXISTS idx_words_lang_cat ON words(to_language_id, category_id);
CREATE INDEX IF NOT EXISTS idx_refresh_expires ON refresh_tokens(expires_at);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON study_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_placement_lang ON placement_questions(language_id);