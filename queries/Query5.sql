-- Query5_SecVGU2.sql
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

DROP PROCEDURE IF EXISTS Query5;
DELIMITER //
CREATE PROCEDURE Query5
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

  DROP TEMPORARY TABLE IF EXISTS TEMP2;
  CREATE TEMPORARY TABLE TEMP2 AS (
    SELECT * FROM TEMP1
    WHERE CASE auth_READ_Enrollment(caller, role, 
      lecturers, students) WHEN TRUE THEN TRUE 
      ELSE throw_error() END
  );

  DROP TEMPORARY TABLE IF EXISTS TEMP3;
  CREATE TEMPORARY TABLE TEMP3 AS (
    SELECT students FROM Enrollment
  );

  IF _rollback = 0
    THEN SELECT COUNT(*) from TEMP3;
  END IF;
END //
DELIMITER ;
