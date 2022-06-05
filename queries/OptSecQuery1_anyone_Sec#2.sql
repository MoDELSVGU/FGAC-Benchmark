-- Opt_Query4_SecVGU1.sql
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
  FROM   (SELECT (EXISTS (SELECT 1 FROM Enrollment 
      WHERE lecturers = kcaller AND kself = students)
    ) as res
  ) AS TEMP;
  RETURN (result);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS Query4Opt;
DELIMITER //
CREATE PROCEDURE Query4Opt
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

IF (role = 'Lecturer'
    AND ((SELECT COUNT(*) FROM Student)
            = (SELECT COUNT(*) FROM Enrollment WHERE lecturers = caller)))
THEN
    DROP TEMPORARY TABLE IF EXISTS TEMP1;
    CREATE TEMPORARY TABLE TEMP1 AS (
    SELECT * FROM Student
    WHERE age > 18
    );
ELSE
    DROP TEMPORARY TABLE IF EXISTS TEMP1;
    CREATE TEMPORARY TABLE TEMP1 AS (
    SELECT * FROM Student
    WHERE CASE auth_READ_Student_age(caller, role, Student_id)
    WHEN 1 THEN age ELSE throw_error() END > 18
    );
END IF;

DROP TEMPORARY TABLE IF EXISTS TEMP2;
CREATE TEMPORARY TABLE TEMP2 AS (
SELECT Student_id AS Student_id FROM TEMP1
);

IF _rollback = 0
THEN SELECT COUNT(*) from TEMP2;
END IF;
END //
DELIMITER ;
