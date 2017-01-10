
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname varchar(255) NOT NULL,
  lname varchar(255) NOT NULL

  --FOREIGN KEY (playwright_id) REFERENCES playwrights(id)
);

DROP TABLE if exists questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title varchar(255) NOT NULL,
  body TEXT,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE if exists question_follows;

CREATE TABLE question_follows (
  --id INTEGER PRIMARY KEY,
  --title varchar(255) NOT NULL,
  --body TEXT,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);


DROP TABLE if exists replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  title varchar(255) NOT NULL,
  body TEXT,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE if exists question_likes;

CREATE TABLE question_likes (
  --id INTEGER PRIMARY KEY,
  --title varchar(255) NOT NULL,
  --body TEXT,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);







INSERT INTO
  users (fname, lname)
VALUES
  ('John', 'VS'),
  ('J', 'LI');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('What is SQL', 'How do i write SQL Im so confused', 1),
  ('What is rails', 'How do i write rails Im so confused', 1),
  ('new_question', 'Another question new question', 2),
  ('??????', 'Another question', 2);


INSERT INTO
  question_follows
VALUES
  (1,1),
  (1,2),
  (2,1);

INSERT INTO
 replies  (title,body,question_id,parent_id,user_id)
VALUES
  ('first reply', 'First relpy body', 1, null, 1),
  ('second reply', 'second relpy body', 1, 1, 1),
  ('third reply', 'Third relpy body', 1, 2, 2);

INSERT INTO
  question_likes
VALUES
  (1,2),
  (1,1),
  (1,3),
  (2,4),
  (2,1);
