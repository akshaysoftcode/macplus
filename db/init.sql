CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_admin BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    owner_id INTEGER REFERENCES users(id)
);

-- password for both demo users is: Password123!
-- (bcrypt hash below is a placeholder pattern — generate real hashes at
-- setup time with `python -c "from passlib.hash import bcrypt; print(bcrypt.hash('Password123!'))"`)
INSERT INTO users (username, password_hash, is_admin) VALUES
    ('alice', '$2b$12$REPLACE_WITH_REAL_BCRYPT_HASH', FALSE),
    ('admin', '$2b$12$REPLACE_WITH_REAL_BCRYPT_HASH', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO items (name, description, owner_id) VALUES
    ('Laptop', 'Company-issued laptop', 1),
    ('Badge', 'Office access badge', 1),
    ('Server rack', 'Admin-only asset', 2)
ON CONFLICT DO NOTHING;
