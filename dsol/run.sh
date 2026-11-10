#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

init_urls

PORTING=$SCRIPTPATH/dsol-tck
OUTPUT=$PORTING/bundles

rm $PORTING/latest-glassfish.zip
rm -rf dsol-tck/payara5

export WORKSPACE=$PORTING
export GF_BUNDLE_URL=$PAYARA_URL
echo Build should download from $GF_BUNDLE_URL

if [ -z "$TCK_BUNDLE_BASE_URL" ]; then
  export TCK_BUNDLE_BASE_URL=http://localhost:8000
fi
if [ -z "$TCK_BUNDLE_FILE_NAME" ]; then
  export TCK_BUNDLE_FILE_NAME=jakarta-debugging-tck-1.0.0.zip
fi

if [ -z $MAVEN_HOME ]; then
    export MAVEN_HOME=`mvn -v | sed -n 's/Maven home: \(.\+\)/\1/p'`
fi

# Replace default value of ${$GF_TOPLEVEL_DIR} (glassfish5) with payara5
sed -i "s/glassfish5/payara5/g" "$WORKSPACE/docker/run_dsoltck.sh"

# Make sure the script doesn't unset JAVA_HOME
if [ -z "$JDK11_HOME" ]; then
  export JDK11_HOME=${JAVA_HOME}
fi

bash -x $WORKSPACE/docker/run_dsoltck.sh | tee $WORKSPACE/dsol.log

# Stop domain because the script doesn't
$WORKSPACE/vi/payara5/bin/asadmin stop-domain


if [ ! -d "$SCRIPTPATH/../results" ]; then
    mkdir $SCRIPTPATH/../results
fi

TIMESTAMP=`date -Iminutes | tr -d :`
report=$SCRIPTPATH/../results/dsol-$TIMESTAMP.tar.gz
echo Creating report $report
tar zcf $report $WORKSPACE/debugging-tck-junit-report.xml $WORKSPACE/vi/payara5/glassfish/domains/domain1/logs

# generate stage log (collected by the Jenkins job from stage_*)
JUNIT=$WORKSPACE/debugging-tck-junit-report.xml
# list every test that did not pass as <classname>#<testcase>  <status>.
FAILED_TESTS=`sed -n -E 's/.*<testcase name="([^"]*)" classname="([^"]*)".* status="([^"]*)".*/\2#\1  \3./p' $JUNIT | grep -v 'Passed\.$'`
cat > $SCRIPTPATH/../stage_dsol << EOF
### dsol

\`\`\`
`sed -n '/<testsuite / p' $JUNIT | sed 's/.* tests="\([0-9]*\)".*/Completed running \1 tests./'`
`sed -n '/<testsuite / p' $JUNIT | sed 's/.* failures="\([0-9]*\)".*/Number of Tests Failed = \1/'`
`sed -n '/<testsuite / p' $JUNIT | sed 's/.* errors="\([0-9]*\)".*/Number of Tests with Errors = \1/'`
`sed -n '/<testsuite / p' $JUNIT | sed 's/.* disabled="\([0-9]*\)".*/Number of Disabled Tests = \1/'`
`sed -n '/<testsuite / p' $JUNIT | sed 's/.* skipped="\([0-9]*\)".*/Number of Skipped Tests = \1/'`
$FAILED_TESTS
\`\`\`
EOF
