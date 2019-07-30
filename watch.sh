FILE=`ls -td cts_home/* | head -1`
echo Watching $FILE
tail -f $FILE | grep "Number of"

