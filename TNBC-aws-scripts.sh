#!/bin/ksh

Project="TNBC-primer3"

# Files to be transferred
file1="nohup.out"
file2="check_UCSC_BSD2.R"
# file1 to be renamed file3
file3="check_UCSC_log.txt"

perl ~/AWS/aws --insecure-aws ls sdf-unix/$Project

dir="/arpa/ns/o/oncoapop/Scripts"
cd $dir
ls -al $file1
ls -al $file2

echo $file1" to be renamed : "$file3
echo " "
echo "Press ENTER if this is correct, Ctrl-C to Abort."
read ans
mv $file1 $file3

echo $file2
echo $file3
echo "Check file(s) to be transferred:"
read ans

echo "Copying file to S3..."

#To copy files to S3
perl ~/AWS/aws --insecure-aws put sdf-unix/$Project/$file2 $dir"/"$file2
perl ~/AWS/aws --insecure-aws put sdf-unix/$Project/$file3 $dir"/"$file3

echo "Transferred."

#To get a file from S3
#curl -k https://s3-us-west-2.amazonaws.com/sdf-unix/TNBC-primer3/$file2 .
#curl -k https://s3-us-west-2.amazonaws.com/sdf-unix/TNBC-primer3/$file3 .

#perl ~/AWS/aws --insecure-aws get sdf-unix/$Project/$file2 .
#perl ~/AWS/aws --insecure-aws get sdf-unix/$Project/$file3 .

echo "check that the files are on S3:"
perl ~/AWS/aws --insecure-aws ls sdf-unix/$Project

