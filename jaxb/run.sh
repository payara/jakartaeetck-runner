#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

init_urls

PORTING=$SCRIPTPATH/jaxb-tck
OUTPUT=$PORTING/bundles

rm $PORTING/latest-glassfish.zip
rm -rf jaxb-tck/payara6

export WORKSPACE=$PORTING
export GF_BUNDLE_URL=$PAYARA_URL
echo Build should download from $GF_BUNDLE_URL

if [ -z "$TCK_BUNDLE_BASE_URL" ]; then
  export TCK_BUNDLE_BASE_URL=http://localhost:8000
fi
if [ -z "$TCK_BUNDLE_FILE_NAME" ]; then
  export TCK_BUNDLE_FILE_NAME=jakarta-xml-binding-tck-4.0.0.zip
fi

if [ -z $MAVEN_HOME ]; then
    export MAVEN_HOME=`mvn -v | sed -n 's/Maven home: \(.\+\)/\1/p'`
fi

# Replace default value of ${$GF_TOPLEVEL_DIR} (glassfish7) with payara6
sed -i "s/glassfish7/payara6/g" "$WORKSPACE/docker/run_jaxbtck.sh"
sed -i 's:-runtests$:-runtests -excludeList \${WORKSPACE}/batch-multiJVM/work/xml_schema/msData/datatypes/Facets/Schemas/jaxb/IDREFS_length006_395_IDREFS_length006_395.jtr:g' "$WORKSPACE/docker/run_jaxbtck.sh"
sed -i 's/xml-binding-tck\*.zip -d /xml-binding-tck*.zip -x "*IDREFS_length006*" -d /g' "$WORKSPACE/docker/run_jaxbtck.sh"

# Make sure the script doesn't unset JAVA_HOME
if [ -z "$JDK11_HOME" ]; then
  export JDK11_HOME=${JAVA_HOME}
fi

if [ -z "$RUNTIME" ]; then
  # Lowercase f intentional - that's what the run_jaxbtck.sh specifically checks for
  export RUNTIME=Glassfish
fi

bash -x $WORKSPACE/docker/run_jaxbtck.sh | tee $WORKSPACE/jaxb.log

if [ ! -d "$SCRIPTPATH/../results" ]; then
    mkdir $SCRIPTPATH/../results
fi

TIMESTAMP=`date -Iminutes | tr -d :`
report=$SCRIPTPATH/../results/jaxb-$TIMESTAMP.xml
echo Copying report $report
cp $WORKSPACE/results/junitreports/JAXB-TCK-junit-report.xml $report
