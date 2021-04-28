#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

init_urls

export PORTING=$SCRIPTPATH/bvtck-porting
OUTPUT=$PORTING/bundles

rm $PORTING/latest-glassfish.zip
rm -rf bvtck-porting/payara6

export WORKSPACE=$PORTING
export GF_BUNDLE_URL=$PAYARA_URL
echo Build should download from $GF_BUNDLE_URL

if [ -z $MAVEN_HOME ]; then
    export MAVEN_HOME=`mvn -v | sed -n 's/Maven home: \(.\+\)/\1/p'`
fi

rm -rf $WORKSPACE/bv-tck-glassfish-porting

bash -x $WORKSPACE/docker/run_bvtck.sh | tee $WORKSPACE/bv.log

TIMESTAMP=`date -Iminutes | tr -d :`
report=$SCRIPTPATH/../results/bv-$TIMESTAMP.tar.gz
echo Creating report $report
tar zcf $report $WORKSPACE/bvtck-report/ $WORKSPACE/payara6/glassfish/domains/domain1/logs

# override BV_TCK_BUNDLE_URL=http://download.eclipse.org/ee4j/bean-validation/beanvalidation-tck-dist-2.0.5.zip 
cat > $SCRIPTPATH/../stage_beanvalidation << EOF
### beanvalidation

\`\`\`
`sed -n "/Tests run:/,/BUILD/ p" $WORKSPACE/bv.log`
\`\`\`
EOF