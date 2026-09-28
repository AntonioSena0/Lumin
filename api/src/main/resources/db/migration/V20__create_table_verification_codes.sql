CREATE TABLE verification_codes (
    email VARCHAR(100) PRIMARY KEY,
    code VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    last_sent_at TIMESTAMP NOT NULL,
    attempts INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP
);