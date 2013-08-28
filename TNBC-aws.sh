#!/bin/ksh

Project="TNBC-primer3"

#perl ~/AWS/aws --insecure-aws ls
#perl ~/AWS/aws --insecure-aws ls sdf-unix
perl ~/AWS/aws --insecure-aws ls sdf-unix/$Project

dir="/arpa/ns/o/oncoapop/Projects/TNBC/primer3"
cd $dir
ls TNBC_is*.csv
ls TNBC_Pri*.csv

echo "Copying file to S3..."
run="6"
isPCR="TNBC_isPCR_chk"$run".csv"
Primers="TNBC_Primers"$run".csv"

isPCRout="TNBC_isPCR_chk.csv"
Primersout="TNBC_Primers.csv"

echo $isPCRout" to be renamed : "$isPCR
echo $Primersout" to be renamed : "$Primers
echo " "
echo "Press ENTER if this is correct, Ctrl-C to Abort."
read ans

mv $isPCRout $isPCR
mv $Primersout $Primers

echo $isPCR
echo $Primers
echo "Check file to be transferred:"
read ans

#To copy files to S3
perl ~/AWS/aws --insecure-aws put sdf-unix/$Project/$isPCR $dir"/"$isPCR
perl ~/AWS/aws --insecure-aws put sdf-unix/$Project/$Primers $dir"/"$Primers

echo "Transferred."

#To get a file from S3
#curl -k
#https://s3-us-west-2.amazonaws.com/sdf-unix/TNBC-primer3/TNBC_Primers1.csv
#perl ~/AWS/aws --insecure-aws get sdf-unix/$Project/$isPCR .
#perl ~/AWS/aws --insecure-aws get sdf-unix/$Project/$Primers .

echo "check that the files are on S3:"
perl ~/AWS/aws --insecure-aws ls sdf-unix/$Project
