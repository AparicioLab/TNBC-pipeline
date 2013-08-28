#!/bin/ksh

echo "My local date is"
TZ=GMT+7 date | sed 's/GMT/PDT/'

cd ~/Scripts

echo "Records processed so far:"
cat nohup.out | grep "Checking" | wc -l

echo "Records failing UCSC:"
cat nohup.out | grep "no UCSC" | wc -l

echo "Records failing my QC:"
cat nohup.out | grep "FAIL" | wc -l

echo "___________________________"

cd ~/Projects/TNBC/primer3
echo "Files processed = check run #"

ls TNBC_isP*.*
ls TNBC_Prim*.*

echo "___________________________"

cd ~/Scripts

script="check_UCSC_BSD2.R"
echo "Script to run: "
echo $script
echo ""
echo "Completed runs using script:"

doneruns=`cat $script | grep "^# Done"`
echo $doneruns

echo "Current run to be executed:"
run=`cat $script | grep "^# Run #"`
echo $run

firstrow=`cat $script | grep "^firstrow="`
echo $firstrow

lastrow=`cat $script | grep "^lastrow="`
echo $lastrow

echo "___________________________"


echo "Press return if this is correct"

read ans

echo "Running script in background"

nohup Rscript check_UCSC_BSD2.R &

ps
