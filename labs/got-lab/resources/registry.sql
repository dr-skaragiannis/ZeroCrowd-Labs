CREATE DATABASE IF NOT EXISTS registry CHARACTER SET utf8mb4;
USE registry;
CREATE TABLE IF NOT EXISTS places (
  id INT PRIMARY KEY,
  name VARCHAR(64) NOT NULL
);
INSERT INTO places (id, name) VALUES
  (1, 'winterfell'),
  (2, 'the rock'),
  (3, 'harbor')
ON DUPLICATE KEY UPDATE name = VALUES(name);
