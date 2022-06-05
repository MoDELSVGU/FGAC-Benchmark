-- Opt_Query5_SecVGU2.sql
DROP FUNCTION IF EXISTS throw_error;
/* FUNC: throw_error */
DELIMITER //
CREATE FUNCTION throw_error()
RETURNS INT DETERMINISTIC
BEGIN
DECLARE result INT DEFAULT 0;
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Unauthorized access';
RETURN (0);
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
  SELECT res INTO result 
  FROM (SELECT ((SELECT MAX(age) FROM Lecturer)
= (SELECT age FROM Lecturer WHERE Lecturer_id = kcaller)) as res
  ) AS TEMP;
  RETURN (result);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS Query5Opt;
DELIMITER //
CREATE PROCEDURE Query5Opt
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
    SELECT Lecturer_id AS lecturers, Student_id AS students 
    FROM Lecturer, Student
  );

IF (role = 'Lecturer'
    AND ((SELECT MAX(age) FROM Lecturer)
    = (SELECT age FROM Lecturer WHERE Lecturer_id = caller)))
THEN
  DROP TEMPORARY TABLE IF EXISTS TEMP2;
  CREATE TEMPORARY TABLE TEMP2 AS (
    SELECT * FROM TEMP1
    WHERE TRUE
  );
ELSE
  DROP TEMPORARY TABLE IF EXISTS TEMP2;
  CREATE TEMPORARY TABLE TEMP2 AS (
    SELECT * FROM TEMP1
    WHERE CASE auth_READ_Enrollment(caller, role, 
      lecturers, students) WHEN TRUE THEN TRUE 
      ELSE throw_error() END
  );
END IF;

  DROP TEMPORARY TABLE IF EXISTS TEMP3;
  CREATE TEMPORARY TABLE TEMP3 AS (
    SELECT students FROM Enrollment
  );

  IF _rollback = 0
    THEN SELECT COUNT(*) from TEMP3;
  END IF;
END //
DELIMITER ;