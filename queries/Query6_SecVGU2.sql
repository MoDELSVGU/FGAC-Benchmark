DROP FUNCTION IF EXISTS auth_READ_Student_age;
/* FUNC: auth_READ_Student_age */
DELIMITER //
CREATE FUNCTION auth_READ_Student_age(
  kcaller varchar(100), krole varchar(100), kself varchar(100)
) RETURNS INT DETERMINISTIC
BEGIN
  DECLARE result INT DEFAULT 0;
  IF (krole = 'Lecturer')
    THEN IF (auth_READ_Student_age_Lecturer(kself, kcaller))
      THEN RETURN (1);
      ELSE RETURN (0);
    END IF;
  ELSE RETURN 0;
  END IF;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS auth_READ_Student_age_Lecturer;
/* FUNC: auth_READ_Student_age_Lecturer */
DELIMITER //
CREATE FUNCTION auth_READ_Student_age_Lecturer(
  kself varchar(100), kcaller varchar(100)
) RETURNS INT DETERMINISTIC
BEGIN
  DECLARE result INT DEFAULT 0;
  SELECT res INTO result 
  FROM (SELECT (EXISTS (
    SELECT 1 FROM Enrollment 
    WHERE lecturers = kcaller AND kself = students)
    )as res
  ) AS TEMP;
  RETURN (result);
END //
DELIMITER ;

DROP FUNCTION IF EXISTS auth_READ_Enrollment;
/* FUNC: auth_READ_Enrollment */
DELIMITER //
CREATE FUNCTION auth_READ_Enrollment(
  kcaller varchar(100), krole varchar(100), 
  klecturers varchar(100), kstudents varchar(100)
) RETURNS INT DETERMINISTIC
BEGIN
  DECLARE result INT DEFAULT 0;
  IF (krole = 'Lecturer')
    THEN IF (auth_READ_Enrollment_Lecturer(klecturers, 
      kstudents, kcaller))
      THEN RETURN (1);
      ELSE RETURN (0);
    END IF;
  ELSE RETURN 0;
  END IF;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS auth_READ_Enrollment_Lecturer;
/* FUNC: auth_READ_Enrollment_Lecturer */
DELIMITER //
CREATE FUNCTION auth_READ_Enrollment_Lecturer(
  klecturers varchar(100), kstudents varchar(100), kcaller varchar(100)
) RETURNS INT DETERMINISTIC
BEGIN
  DECLARE result INT DEFAULT 0;
  SELECT res INTO result FROM 
  (SELECT ((klecturers = kcaller) OR (EXISTS (SELECT 1 FROM Enrollment 
      WHERE lecturers = kcaller AND kstudents = students)
    )) as res
  ) AS TEMP;
  RETURN (result);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS Query6;
DELIMITER //
CREATE PROCEDURE Query6
  (in caller varchar(250), in role varchar(250))
BEGIN
DECLARE _rollback int DEFAULT 0;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
  SET _rollback = 1;
  GET STACKED DIAGNOSTICS CONDITION 1 
    @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
  SELECT @p1, @p2;
  ROLLBACK;
  END;
  START TRANSACTION;

  DROP TEMPORARY TABLE IF EXISTS TEMP1;
  CREATE TEMPORARY TABLE TEMP1 AS (
    SELECT Student_id AS students, Lecturer_id AS lecturers
    FROM Student, Lecturer
    WHERE Lecturer_id = caller
  );

  DROP TEMPORARY TABLE IF EXISTS TEMP2;
  CREATE TEMPORARY TABLE TEMP2 AS (
    SELECT * FROM TEMP1
    WHERE CASE auth_READ_Enrollment(caller, role, 
      lecturers, students) WHEN TRUE THEN TRUE 
      ELSE throw_error() END
  );

  DROP TEMPORARY TABLE IF EXISTS TEMP3;  
  CREATE TEMPORARY TABLE TEMP3 AS (
    SELECT * FROM Student JOIN TEMP2 
    ON Student_id = students
  );

  DROP TEMPORARY TABLE IF EXISTS TEMP4;
  CREATE TEMPORARY TABLE TEMP4 AS (
    SELECT CASE auth_READ_Student_age(caller, role,
      Student_id) WHEN 1 THEN age ELSE throw_error() END as age 
    FROM TEMP3
  );

  IF _rollback = 0
    THEN SELECT age from TEMP4;
  END IF;
END //
DELIMITER ;

call Query6('lid1', 'Lecturer');