#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

init_urls

PORTING=$SCRIPTPATH/ditck-porting
OUTPUT=$PORTING/bundles

rm $PORTING/latest-glassfish.zip

rm -rf ditck-porting/jakarta.inject-tck-*/
rm -rf ditck-porting/cdi-tck-*/

export WORKSPACE=$SCRIPTPATH/ditck-porting
export GF_BUNDLE_URL=$PAYARA_URL
export JSR299_TCK_URL=$CDI_TCK_URL
export JAVAX_INJECT_TCK_URL=$DI_TCK_URL
echo Build should download from $GF_BUNDLE_URL

if [ -z $MAVEN_HOME ]; then
    export MAVEN_HOME=`mvn -v | sed -n 's/Maven home: \(.\+\)/\1/p'`
fi

rm -rf $WORKSPACE/330-tck-glassfish-porting

bash -x $WORKSPACE/docker/run_ditck.sh | tee $WORKSPACE/di.log

cat > $SCRIPTPATH/../stage_di <<EOF
### di 

\`\`\`
`grep "Tests run:" -B 1 $WORKSPACE/di.log`
\`\`\`
EOF

TIMESTAMP=`date -Iminutes | tr -d :`
report=$SCRIPTPATH/../results/di-$TIMESTAMP.tar.gz
echo Creating report $report
tar zcf $report $WORKSPACE/330tck-report/ $WORKSPACE/payara5/glassfish/domains/domain1/logs
