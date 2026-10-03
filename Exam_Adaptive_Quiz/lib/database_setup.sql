CREATE DATABASE exam_prep;

USE exam_prep;

USE exam_prep;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    ability DOUBLE DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE topics (
    topic_id INT AUTO_INCREMENT PRIMARY KEY,
    topic_name VARCHAR(100) NOT NULL,
    subject VARCHAR(100) NOT NULL
);

CREATE TABLE questions (
    question_id INT AUTO_INCREMENT PRIMARY KEY,
    topic_id INT NOT NULL,
    question_text TEXT NOT NULL,
    option_a VARCHAR(255) NOT NULL,
    option_b VARCHAR(255) NOT NULL,
    option_c VARCHAR(255) NOT NULL,
    option_d VARCHAR(255) NOT NULL,
    correct_option CHAR(1) NOT NULL,
    difficulty DOUBLE DEFAULT 0.0,
    discrimination DOUBLE DEFAULT 1.0,

    FOREIGN KEY (topic_id)
        REFERENCES topics(topic_id)
);

INSERT INTO topics (topic_name, subject)
VALUES
('Arrays', 'DSA'),
('Recursion', 'DSA'),
('Graphs', 'DSA'),
('OOP', 'Java'),
('SQL', 'DBMS');

SELECT * FROM topics;

INSERT INTO questions
(topic_id, question_text, option_a, option_b, option_c, option_d,
 correct_option, difficulty, discrimination)
VALUES

(1,
 'What is the index of the first element in a standard array?',
 '0',
 '1',
 '-1',
 'Depends on the array',
 'A',
 -1.0,
 1.0),

(2,
 'Which technique involves a function calling itself?',
 'Iteration',
 'Recursion',
 'Compilation',
 'Sorting',
 'B',
 0.0,
 1.2),

(3,
 'Which data structure is commonly used in Breadth First Search?',
 'Stack',
 'Queue',
 'Heap',
 'Array',
 'B',
 0.5,
 1.1),

(4,
 'Which OOP concept allows a class to have multiple forms?',
 'Encapsulation',
 'Inheritance',
 'Polymorphism',
 'Abstraction',
 'C',
 0.8,
 1.3),

(5,
 'Which SQL command is used to retrieve data?',
 'INSERT',
 'UPDATE',
 'SELECT',
 'DELETE',
 'C',
 -0.5,
 1.0);
 
 
 SELECT * FROM questions;
 
 SELECT
    q.question_id,
    q.question_text,
    t.topic_name,
    t.subject,
    q.difficulty
FROM questions q
JOIN topics t
ON q.topic_id = t.topic_id;

SHOW TABLES;

USE exam_prep;

CREATE TABLE quiz_attempts (
    attempt_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    score INT NOT NULL,
    total_questions INT NOT NULL,
    ability_before DOUBLE DEFAULT 0.0,
    ability_after DOUBLE DEFAULT 0.0,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
);

CREATE TABLE answers (
    answer_id INT AUTO_INCREMENT PRIMARY KEY,
    attempt_id INT NOT NULL,
    question_id INT NOT NULL,
    selected_option CHAR(1) NOT NULL,
    is_correct BOOLEAN NOT NULL,
    response_time_seconds INT DEFAULT 0,

    FOREIGN KEY (attempt_id)
        REFERENCES quiz_attempts(attempt_id),

    FOREIGN KEY (question_id)
        REFERENCES questions(question_id)
);

INSERT INTO users
(name, email, password, ability)
VALUES
('Test Student', 'student@test.com', '123456', 0.0);

SELECT * FROM users;

INSERT INTO quiz_attempts
(user_id, score, total_questions, ability_before, ability_after)
VALUES
(1, 3, 5, 0.0, 0.4);

INSERT INTO answers
(attempt_id, question_id, selected_option, is_correct, response_time_seconds)
VALUES
(1, 1, 'A', TRUE, 12),
(1, 2, 'B', TRUE, 18),
(1, 3, 'A', FALSE, 25),
(1, 4, 'C', TRUE, 15),
(1, 5, 'A', FALSE, 20);