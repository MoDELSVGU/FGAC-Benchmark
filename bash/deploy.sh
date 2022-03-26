#!/bin/bash

SQLU="root"
SQLP="Abc@12345"
CLEAN_FIRST=false

cd ..

if [ "$CLEAN_FIRST" = true ] ; then
    echo "Clean databases..."
    cd databases
    mysql -u$SQLU -p$SQLP < ./clean.sql

    echo "Init databases..."
    for i in 100 200 300 400 500 600 700 800 900 1000
    do
        echo "[vgu$i]: Init database schema"
        mysql -u$SQLU -p$SQLP < ./vgu$i.sql
        echo "[vgu$i]: Init database scenario"
        mysql -u$SQLU -p$SQLP vgu$i --local-infile --execute "LOAD DATA LOCAL INFILE 'lecturer$i' INTO TABLE Lecturer FIELDS TERMINATED BY ',' LINES STARTING BY '#' TERMINATED BY '\n' ("lecturer_id", "name", "age", "email"); SHOW WARNINGS";
        mysql -u$SQLU -p$SQLP vgu$i --local-infile --execute "LOAD DATA LOCAL INFILE 'student$i' INTO TABLE Student FIELDS TERMINATED BY ',' LINES STARTING BY '#' TERMINATED BY '\n' ("student_id", "name", "age", "email"); SHOW WARNINGS";
        mysql -u$SQLU -p$SQLP vgu$i --local-infile --execute "LOAD DATA LOCAL INFILE 'enrollment$i' INTO TABLE Enrollment FIELDS TERMINATED BY ',' LINES STARTING BY '#' TERMINATED BY '\n' ("students", "lecturers"); SHOW WARNINGS";
    done
    cd ..
fi



echo "Running benchmark..."
for EXM in "Query4" "AppLayer4" "SecQuery4" "OptSecQuery4" "SecQuery5" "OptSecQuery5" "Query5" "AppLayer5" "SecQuery6" "OptSecQuery6" "Query6" "AppLayer6"
do
    echo "Setting up Example of $EXM"
    cd queries
    for i in 100 200 300 400 500 600 700 800 900 1000
    do
        echo "[vgu$i]: Setting up"
        mysql -u$SQLU -p$SQLP vgu$i < $EXM.sql
    done
    cd ..
    echo "Done setting up Example of $EXM"
    
    echo "Running benchmark: Example of $EXM"
    cd scripts
    python benchmark.py -bm -c $EXM -u $SQLU -p $SQLP
    cd ..
done
echo "...Done running benchmark"


$SHELL