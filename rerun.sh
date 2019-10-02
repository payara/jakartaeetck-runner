#!/bin/bash
#
# Copyright (c) 2018, 2019 Oracle and/or its affiliates. All rights reserved.
# Copyright (c) 2019 Payara Foundation and/or its affiliates. All rights reserved.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v. 2.0, which is available at
# http://www.eclipse.org/legal/epl-2.0.
#
# This Source Code may also be made available under the following Secondary
# Licenses when the conditions for such availability set forth in the
# Eclipse Public License v. 2.0 are satisfied: GNU General Public License,
# version 2 with the GNU Classpath Exception, which is available at
# https://www.gnu.org/software/classpath/license.html.
#
# SPDX-License-Identifier: EPL-2.0 OR GPL-2.0 WITH Classpath-exception-2.0
#
# Excerpt of run_javaeetck.sh to rerun the test cases (after reapplying ts.jte overrides)

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/functions.sh

export CTS_HOME=$SCRIPTPATH/cts_home
export WORKSPACE=$CTS_HOME/jakartaeetck

apply_overrides

### initialize variables
if [[ $1 = *'_'* ]]; then
  test_suite=`echo "$1" | cut -f1 -d_`
  vehicle_name=`echo "$1" | cut -f2 -d_`
  vehicle="${vehicle_name}_vehicle"
else
  test_suite="$1"
  vehicle=""
fi

echo "TEST_SUITE:${test_suite}."
echo "VEHICLE:${vehicle}."

if [ -z "${test_suite}" ]; then
  echo "Please supply a valid test_suite as argument"
  exit 1
fi

if [ -z "${CTS_HOME}" ]; then
  export CTS_HOME="${WORKSPACE}"
fi
export TS_HOME=${CTS_HOME}/jakartaeetck/

export CTS_ANT_OPTS="-Djava.endorsed.dirs=${CTS_HOME}/vi/$GF_VI_TOPLEVEL_DIR/glassfish/modules/endorsed \
-Djavax.xml.accessExternalStylesheet=all \
-Djavax.xml.accessExternalSchema=all \
-Djavax.xml.accessExternalDTD=file,http"

if [[ "$PROFILE" == "web" || "$PROFILE" == "WEB" ]];then
  KEYWORDS="javaee_web_profile|jacc_web_profile|jaspic_web_profile|javamail_web_profile|connector_web_profile"
fi

if [ -z "${vehicle}" ];then
  echo "Vehicle not set. Running all vehichles"
else
  echo "Vehicle set. Running in vehicle: ${vehicle}"
  if [ -z "${KEYWORDS}" ]; then
    KEYWORDS=${vehicle}
  else
    KEYWORDS="(${KEYWORDS} & ${vehicle})"
  fi
fi

if [ ! -z "$KEYWORDS" ];then
  if [ ! -z "$USER_KEYWORDS" ]; then
    KEYWORDS="${KEYWORDS}${USER_KEYWORDS}"
  fi
else
  if [ ! -z "$USER_KEYWORDS" ]; then
    KEYWORDS="${USER_KEYWORDS}"
  fi
fi

if [ ! -z "${KEYWORDS}" ]; then
  CTS_ANT_OPTS="${CTS_ANT_OPTS} -Dkeywords=\"${KEYWORDS}\""
fi

echo "CTS_ANT_OPTS:${CTS_ANT_OPTS}"
echo "KEYWORDS:${KEYWORDS}"
		
export JT_REPORT_DIR=${CTS_HOME}/jakartaeetck-report
export JT_WORK_DIR=${CTS_HOME}/jakartaeetck-work

### Rerun tests
cd $TS_HOME/bin;
# Check if there are any failures in the test. If so, re-run those tests.
FAILED_COUNT=0
ERROR_COUNT=0
TEST_SUITE=`echo "${test_suite}" | tr '/' '_'`
FAILED_COUNT=`cat ${JT_REPORT_DIR}/${TEST_SUITE}/text/summary.txt | grep 'Failed.' | wc -l`
ERROR_COUNT=`cat ${JT_REPORT_DIR}/${TEST_SUITE}/text/summary.txt | grep 'Error.' | wc -l`

rerun_log=${CTS_HOME}/${TEST_SUITE}_rerun.log
echo "Failed tests: ${FAILED_COUNT}" | tee $rerun_log
echo "Errored tests: ${ERROR_COUNT}" | tee -a $rerun_log
RUN_CLIENT_ARGS=""
if [[ $FAILED_COUNT -gt 0 || $ERROR_COUNT -gt 0 ]]; then
  echo "One or more tests failed. Failure count:$FAILED_COUNT/Error count:$ERROR_COUNT"
  echo "Re-running only the failed, error tests"
  if [[ "jbatch" == ${test_suite} ]]; then
    RUN_CLIENT_ARGS="-DpriorStatus=fail"
  else 
    RUN_CLIENT_ARGS='-Drun.client.args="-DpriorStatus=fail,error"'
  fi
fi
if [ -z "$KEYWORDS" ]; then
  if [[ "jbatch" == ${test_suite} ]]; then
    cd $TS_HOME/src/com/ibm/jbatch/tck;
    ant runclient $RUN_CLIENT_ARGS -Dwork.dir=${JT_WORK_DIR}/jbatch -Dreport.dir=${JT_REPORT_DIR}/jbatch |& tee -a $rerun_log
  else
    ant -f xml/impl/glassfish/s1as.xml run.cts -Dant.opts="${CTS_ANT_OPTS} ${ANT_OPTS}" $RUN_CLIENT_ARGS  -DbuildJwsJaxws=false -Dtest.areas="${test_suite}" |& tee -a $rerun_log
  fi
else
  if [[ "jbatch" == ${test_suite} ]]; then
    cd $TS_HOME/src/com/ibm/jbatch/tck;
    ant runclient $RUN_CLIENT_ARGS -Dkeywords=\"${KEYWORDS}\" -Dwork.dir=${JT_WORK_DIR}/jbatch -Dreport.dir=${JT_REPORT_DIR}/jbatch |& tee -a $rerun_log
  else
    ant -f xml/impl/glassfish/s1as.xml run.cts -Dkeywords=\"${KEYWORDS}\" -Dant.opts="${CTS_ANT_OPTS} ${ANT_OPTS}" $RUN_CLIENT_ARGS  -DbuildJwsJaxws=false -Dtest.areas="${test_suite}" |& tee -a $rerun_log
  fi
fi
  # Generate combined report for both the runs.
if [[ "jbatch" == ${test_suite} ]]; then
  ant -Dreport.for=com/ibm/jbatch/tck -Dwork.dir=${JT_WORK_DIR}/jbatch -Dreport.dir=${JT_REPORT_DIR}/jbatch report |& tee -a $rerun_log
else  
  ant -Dreport.for=com/sun/ts/tests/$test_suite -Dreport.dir=${JT_REPORT_DIR}/${TEST_SUITE} -Dwork.dir=${JT_WORK_DIR}/${TEST_SUITE} report |& tee -a $rerun_log
fi


export HOST=`hostname -f`
echo "1 ${TEST_SUITE} ${HOST}" > ${CTS_HOME}/args.txt
mkdir -p ${WORKSPACE}/results/junitreports/
${JAVA_HOME}/bin/java -Djunit.embed.sysout=true -jar ${TS_HOME}/docker/JTReportParser/JTReportParser.jar ${CTS_HOME}/args.txt ${JT_REPORT_DIR} ${WORKSPACE}/results/junitreports/
rm -f ${CTS_HOME}/args.txt

if [ -z ${vehicle} ];then
  RESULT_FILE_NAME=${TEST_SUITE}-results.tar.gz
else
  RESULT_FILE_NAME=${TEST_SUITE}_${vehicle_name}-results.tar.gz
  sed -i "s/name=\"${TEST_SUITE}\"/name=\"${TEST_SUITE}_${vehicle_name}\"/g" ${WORKSPACE}/results/junitreports/${TEST_SUITE}-junit-report.xml
  mv ${WORKSPACE}/results/junitreports/${TEST_SUITE}-junit-report.xml  ${WORKSPACE}/results/junitreports/${TEST_SUITE}_${vehicle_name}-junit-report.xml
fi
tar zcvf ${WORKSPACE}/${RESULT_FILE_NAME} ${CTS_HOME}/*.log ${JT_REPORT_DIR} ${JT_WORK_DIR} ${WORKSPACE}/results/junitreports/ ${CTS_HOME}/jakartaeetck/bin/ts.* ${CTS_HOME}/vi/$GF_VI_TOPLEVEL_DIR/glassfish/domains/domain1/

if [ -z ${vehicle} ];then
  JUNIT_REPORT_FILE_NAME=${TEST_SUITE}-junitreports.tar.gz
else
  JUNIT_REPORT_FILE_NAME=${TEST_SUITE}_${vehicle_name}-junitreports.tar.gz
fi
tar zcvf ${WORKSPACE}/${JUNIT_REPORT_FILE_NAME} ${WORKSPACE}/results/junitreports/