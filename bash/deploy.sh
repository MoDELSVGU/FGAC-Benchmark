#!/bin/bash

SQLU="sosym21"
SQLP="sosym21"
CLEAN_FIRST=true
n=30

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
        mysql -u$SQLU -p$SQLP vgu$i --local-infile --execute "LOAD DATA LOCAL INFILE 'lecturer$i' INTO TABLE Lecturer FIELDS TERMINATED BY ',' LINES STARTING BY '#' TERMINATED BY '\n' ("Lecturer_id", "name", "age", "email"); SHOW WARNINGS";
        mysql -u$SQLU -p$SQLP vgu$i --local-infile --execute "LOAD DATA LOCAL INFILE 'student$i' INTO TABLE Student FIELDS TERMINATED BY ',' LINES STARTING BY '#' TERMINATED BY '\n' ("Student_id", "name", "age", "email"); SHOW WARNINGS";
        mysql -u$SQLU -p$SQLP vgu$i --local-infile --execute "LOAD DATA LOCAL INFILE 'enrollment$i' INTO TABLE Enrollment FIELDS TERMINATED BY ',' LINES STARTING BY '#' TERMINATED BY '\n' ("students", "lecturers"); SHOW WARNINGS";
    done
    cd ..
fi



echo "Running benchmark..."
for EXM in "Query1" "SecQuery1_Michel_Sec#1" "SecQuery1_Vinh_Sec#1" "SecQuery1_anyone_Sec#2" "OptSecQuery1_Michel_Sec#1" "OptSecQuery1_Vinh_Sec#1" "OptSecQuery1_anyone_Sec#2" "Query2" "SecQuery2_Michel_Sec#1" "SecQuery2_Vinh_Sec#1" "SecQuery2_anyone_Sec#2" "OptSecQuery2_Michel_Sec#1" "OptSecQuery2_Vinh_Sec#1" "OptSecQuery2_anyone_Sec#2"
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
    for ((i=1;i<=n;i++))
    do 
        python3 benchmark.py -bm -c $EXM -u $SQLU -p $SQLP -i $i
        echo "Restarting MySQL Server"
        service mysql restart
    done
    cd ..
done
echo "...Done running benchmark"


$SHELL
