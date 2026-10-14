CREATE TABLE IF NOT EXISTS places (
  id INT PRIMARY KEY,
  name TEXT NOT NULL
);
INSERT INTO places (id, name) VALUES
  (1, 'winterfell'),
  (2, 'the rock')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
