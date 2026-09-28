CREATE TYPE provider_type AS ENUM ('GOOGLE', 'FACEBOOK', 'X');

CREATE TABLE oauth_accounts (
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider provider_type NOT NULL,
    provider_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (provider, provider_id)
);
