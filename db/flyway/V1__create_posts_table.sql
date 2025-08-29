CREATE TABLE posts (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    content VARCHAR(1000) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    content_vector tsvector
);

-- Optionally, create an index for the content_vector column for full-text search
CREATE INDEX idx_posts_content_vector ON posts USING GIN (content_vector);
