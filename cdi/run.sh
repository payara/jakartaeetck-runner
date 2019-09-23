#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

init_urls

PORTING=$SCRIPTPATH/cditck-porting

rm $PORTING/latest_glassfish.zip
rm -rf cditck-porting/payara5

# install CDI TCK into local maven repo
. ./install.sh

export WORKSPACE=$SCRIPTPATH/cditck-porting
export GF_BUNDLE_URL=$PAYARA_URL
echo Build should download from $GF_BUNDLE_URL

if [ -z $MAVEN_HOME ]; then
    export MAVEN_HOME=`mvn -v | sed -n 's/Maven home: \(.\+\)/\1/p'`
fi
if [ -z $M2_HOME ]; then
    export M2_HOME=$MAVEN_HOME
fi

rm -rf $WORKSPACE/cdi-tck-glassfish-porting

bash -x $WORKSPACE/docker/run_cditck.sh | tee $WORKSPACE/cdi.log

TIMESTAMP=`date -Iminutes | tr -d :`
report=$SCRIPTPATH/../results/cdi-$TIMESTAMP.tar.gz
echo Creating report $report
tar zcf $report $WORKSPACE/cdi-tck-report/ $WORKSPACE/payara5/glassfish/domains/domain1/logs

