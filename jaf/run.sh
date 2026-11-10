#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

init_urls

PORTING=$SCRIPTPATH/jaf-tck
OUTPUT=$PORTING/bundles

rm $PORTING/latest-glassfish.zip
rm -rf jaf-tck/payara6

export WORKSPACE=$PORTING
export GF_BUNDLE_URL=$PAYARA_URL
echo Build should download from $GF_BUNDLE_URL

if [ -z "$TCK_BUNDLE_BASE_URL" ]; then
  export TCK_BUNDLE_BASE_URL=http://localhost:8000
fi
if [ -z "$TCK_BUNDLE_FILE_NAME" ]; then
  export TCK_BUNDLE_FILE_NAME=jakarta-activation-tck-2.1.2.zip
fi

export ACTIVATION_BUNDLE_URL=https://repo1.maven.org/maven2/jakarta/activation/jakarta.activation-api/2.1.4/jakarta.activation-api-2.1.4.jar
echo Build should download from $ACTIVATION_BUNDLE_URL
export ANGUS_BUNDLE_URL=https://repo1.maven.org/maven2/org/eclipse/angus/angus-activation/1.1.0/angus-activation-1.1.0.jar
echo Build should download from $ANGUS_BUNDLE_URL

if [ -z $MAVEN_HOME ]; then
    export MAVEN_HOME=`mvn -v | sed -n 's/Maven home: \(.\+\)/\1/p'`
fi

sed -i "s/glassfish7/payara6/g" "$WORKSPACE/docker/run_activationtck.sh"

# fix broken running script
# add missing argument with path
sed -i 's/echo "1 /echo "1 html /g' "$WORKSPACE/docker/run_activationtck.sh"
# create separate directory with pluggability report
sed -ni 'p; s|mkdir -p $WORKSPACE/results/junitreports|mkdir -p $WORKSPACE/results/junitreports-pluggability|p' "$WORKSPACE/docker/run_activationtck.sh"
# run the converter again for pluggability report
sed -ni 'p; s|args.txt $JT_REPORT_DIR $WORKSPACE/results/junitreports/|args.txt ${JT_REPORT_DIR}-Pluggability $WORKSPACE/results/junitreports-pluggability/|p' "$WORKSPACE/docker/run_activationtck.sh"
# tar both results
sed -i 's|^tar \(.*\)$|tar \1 ${JT_REPORT_DIR}-Pluggability $WORKSPACE/results/junitreports-pluggability|g' "$WORKSPACE/docker/run_activationtck.sh"


bash -x $WORKSPACE/docker/run_activationtck.sh | tee $WORKSPACE/bv.log

if [ ! -d "$SCRIPTPATH/../results" ]; then
    mkdir $SCRIPTPATH/../results
fi

TIMESTAMP=`date -Iminutes | tr -d :`
report=$SCRIPTPATH/../results/jaf-$TIMESTAMP.tar.gz
echo Creating report $report
tar zcf $report $WORKSPACE/activation-tck/JTreport/ $WORKSPACE/activation-tck/JTreport-Pluggability/ $WORKSPACE/results $SCRIPTPATH/payara6/glassfish/domains/domain1/logs

# generate stage log (collected by the Jenkins job from stage_*)
# the regular and the pluggability run each have their own junit report, so sum up both
JUNIT_FILES=`ls $WORKSPACE/results/junitreports*/*-junit-report.xml`
sum_attr () {
    sed -n '/<testsuite / p' $JUNIT_FILES | sed -n "s/.* $1=\"\([0-9]*\)\".*/\1/p" | awk '{s+=$1} END {print s+0}'
}
# list every test that did not pass, one per line, as "<classname>#<testcase>  <status>." (same format as the main runner's summary.txt)
FAILED_TESTS=`sed -n -E 's/.*<testcase name="([^"]*)" classname="([^"]*)".* status="([^"]*)".*/\2#\1  \3./p' $JUNIT_FILES | grep -v 'Passed\.$'`
cat > $SCRIPTPATH/../stage_activation << EOF
### activation

\`\`\`
Completed running `sum_attr tests` tests.
Number of Tests Failed = `sum_attr failures`
Number of Tests with Errors = `sum_attr errors`
Number of Disabled Tests = `sum_attr disabled`
Number of Skipped Tests = `sum_attr skipped`
$FAILED_TESTS
\`\`\`
EOF
