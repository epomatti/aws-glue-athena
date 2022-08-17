USE testdb;

CREATE TABLE PERSON (
  ID INT NOT NULL AUTO_INCREMENT,
  NAME VARCHAR(255),
  BIRTHDAY DATE,
  SEX VARCHAR(1),
  FAVORITE_FOOD VARCHAR(50),
  PRIMARY KEY (ID)
);

INSERT INTO PERSON (NAME, BIRTHDAY, SEX, FAVORITE_FOOD) VALUES ('John', '1998-03-15', 'M', 'Pasta');
INSERT INTO PERSON (NAME, BIRTHDAY, SEX, FAVORITE_FOOD) VALUES ('Carol', '1958-02-11', 'F', 'Icecream');
INSERT INTO PERSON (NAME, BIRTHDAY, SEX, FAVORITE_FOOD) VALUES ('Andrew', '2001-07-15', 'M', 'Lasagna');
INSERT INTO PERSON (NAME, BIRTHDAY, SEX, FAVORITE_FOOD) VALUES ('Michael', '1977-12-01', 'M', 'Pizza');
INSERT INTO PERSON (NAME, BIRTHDAY, SEX, FAVORITE_FOOD) VALUES ('Anna', '1988-05-13', 'F', 'Steak');
