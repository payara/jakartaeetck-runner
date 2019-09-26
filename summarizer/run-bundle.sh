process_targz () {
  rm -rf bundle/
  mkdir bundle
  tar zxf $1 -C bundle/
  JUNIT=`find bundle -name '*-junit-report.xml'`
  LOG=`find bundle -name domain1`/logs
  echo Will enalyze $JUNIT against $LOG
  java -jar target/tck-summarizer-1.0-SNAPSHOT.jar $JUNIT $LOG
}

if [ -z $1 ]; then
   echo Usage: $0 '<directory with slim reports>'
   exit
fi

for report in `find $1 -name '*-results.slim.tar.gz'`; do
  echo Processing $report
  process_targz $report
done

