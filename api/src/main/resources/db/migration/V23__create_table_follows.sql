CREATE TABLE follows (
    follower_id BIGINT NOT NULL,
    followed_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (follower_id, followed_id),
    CONSTRAINT fk_follows_follower FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_follows_followed FOREIGN KEY (followed_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT ck_follows_not_self CHECK (follower_id <> followed_id)
);

CREATE INDEX idx_follows_followed ON follows (followed_id);
