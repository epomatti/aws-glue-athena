USE testdb;

CREATE TABLE PERSON (
  ID INT NOT NULL AUTO_INCREMENT,
  NAME VARCHAR(255),
  BIRTHDAY DATE,
  SEX VARCHAR(1),
  FAVORITE_FOOD VARCHAR(50),
  PRIMARY KEY (ID)
);

INSERT INTO PERSON
  (NAME, BIRTHDAY, SEX, FAVORITE_FOOD)
VALUES
  ('John', '1998-03-15', 'M', 'Pasta'),
  ('Carol', '1958-02-11', 'F', 'Icecream'),
  ('Andrew', '2001-07-15', 'M', 'Lasagna'),
  ('Michael', '1977-12-01', 'M', 'Pizza'),
  ('Anna', '1988-05-13', 'F', 'Steak');
