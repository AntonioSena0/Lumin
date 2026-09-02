ALTER TABLE users ADD COLUMN avatar_id INTEGER DEFAULT 1;
ALTER TABLE users ADD CONSTRAINT fk_users_avatars FOREIGN KEY (avatar_id) REFERENCES avatars(id);
