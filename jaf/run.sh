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
  export TCK_BUNDLE_FILE_NAME=activation-tck-2.1.0.zip
fi

if [ -z $MAVEN_HOME ]; then
    export MAVEN_HOME=`mvn -v | sed -n 's/Maven home: \(.\+\)/\1/p'`
fi

sed -i "s/glassfish7/payara6/g" "$WORKSPACE/docker/run_activationtck.sh"

bash -x $WORKSPACE/docker/run_activationtck.sh | tee $WORKSPACE/bv.log

TIMESTAMP=`date -Iminutes | tr -d :`
report=$SCRIPTPATH/../results/jaf-$TIMESTAMP.tar.gz
echo Creating report $report
tar zcf $report $WORKSPACE/activation-tck/JTreport/ $SCRIPTPATH/payara6/glassfish/domains/domain1/logs