#!/bin/bash

SQLP="Golden123"

echo "Clean databases..."
cd ../databases/
mysql -uroot -p$SQLP < ./clean.sql
echo "...Done cleaning databases"

# SET GLOBAL local_infile = true;

echo "Init databases..."
for i in 100 200 
# 300 400 500 600 700 800 900 1000
do
    mysql -uroot -p$SQLP < ./vgu$i.sql
    mysql -uroot -p$SQLP vgu$i --local-infile --execute "LOAD DATA LOCAL INFILE 'lecturer$i' INTO TABLE Lecturer FIELDS TERMINATED BY ',' LINES STARTING BY '#' TERMINATED BY '\r\n' ("lecturer_id", "name", "age", "email"); SHOW WARNINGS";
    mysql -uroot -p$SQLP vgu$i --local-infile --execute "LOAD DATA LOCAL INFILE 'student$i' INTO TABLE Student FIELDS TERMINATED BY ',' LINES STARTING BY '#' TERMINATED BY '\r\n' ("student_id", "name", "age", "email"); SHOW WARNINGS";
    mysql -uroot -p$SQLP vgu$i --local-infile --execute "LOAD DATA LOCAL INFILE 'enrollment$i' INTO TABLE Enrollment FIELDS TERMINATED BY ',' LINES STARTING BY '#' TERMINATED BY '\r\n' ("students", "lecturers"); SHOW WARNINGS";
done
cd ..
echo "...Done init databases"

echo "Running benchmark..."
for EXM in "Query4" "OptQuery4" "Query5" "OptQuery5" "Query6" "OptQuery6"
do
    echo "Setting up Example of $EXM"
    cd queries
    for i in 100 200 
    # 300 400 500 600 700 800 900 1000
    do
        echo "[vgu$i]: Setting up"
        mysql -uroot -p$SQLP vgu$i < $EXM.sql
        echo "[vgu$i]: Done"
    done
    cd ..
    echo "Done setting up Example of $EXM"
    
    echo "Running benchmark: Example of $EXM"
    cd scripts
    python benchmark.py -bm -c $EXM
    cd ..
    echo "Done running benchmark: Example of $EXM"
done
echo "...Done running benchmark"


$SHELL