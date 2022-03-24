DROP DATABASE IF EXISTS vgu200;
CREATE DATABASE vgu200 
 DEFAULT CHARACTER SET utf8mb4 
 DEFAULT COLLATE utf8_general_ci;
USE vgu200;
CREATE TABLE Lecturer (Lecturer_id VARCHAR (100) NOT NULL PRIMARY KEY, email VARCHAR (100) , name VARCHAR (100) , age INT(11));
CREATE TABLE Student (Student_id VARCHAR (100) NOT NULL PRIMARY KEY, name VARCHAR (100) , email VARCHAR (100) , age INT(11));
CREATE TABLE Enrollment (lecturers VARCHAR (100), students VARCHAR (100));
ALTER TABLE Enrollment ADD FOREIGN KEY (lecturers) REFERENCES Lecturer (Lecturer_id), ADD FOREIGN KEY (students) REFERENCES Student (Student_id);

