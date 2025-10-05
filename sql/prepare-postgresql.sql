-- Create a table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(150),
    age INT,
    created_at TIMESTAMP DEFAULT now()
);

-- Insert some dummy data
INSERT INTO users (name, email, age) VALUES
('Alice Smith', 'alice@example.com', 28),
('Bob Johnson', 'bob@example.com', 35),
('Charlie Brown', 'charlie@example.com', 22),
('Diana Prince', 'diana@example.com', 30),
('Evan Wright', 'evan@example.com', 40);
