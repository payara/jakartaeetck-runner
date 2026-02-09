#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

echo -----------------------------------------------------------------------
echo Scriptpath: ${SCRIPTPATH}
echo -----------------------------------------------------------------------

init_urls

PORTING=$SCRIPTPATH/jaf-tck
OUTPUT=$PORTING/bundles

if [ ! -d jaf-tck ]; then
   git clone https://github.com/eclipse-ee4j/jaf-tck
fi

rm -f $PORTING/latest-glassfish.zip
rm -rf $OUTPUT
rm -rf $PORTING/dist/
rm -rf $PORTING/payara6

export WORKSPACE=$PORTING
export GF_BUNDLE_URL=$PAYARA_URL
echo Build should download from $GF_BUNDLE_URL

if [ -z "$TCK_BUNDLE_BASE_URL" ]; then
  export TCK_BUNDLE_BASE_URL=http://localhost:8000
fi
if [ -z "$TCK_BUNDLE_FILE_NAME" ]; then
  export TCK_BUNDLE_FILE_NAME=jakarta-activation-tck-2.1.0.zip
fi

export ACTIVATION_BUNDLE_URL=https://repo1.maven.org/maven2/com/sun/activation/jakarta.activation/2.0.0/jakarta.activation-2.0.0.jar
echo Build should download from $ACTIVATION_BUNDLE_URL
export ANGUS_BUNDLE_URL=https://repo1.maven.org/maven2/org/eclipse/angus/angus-activation/1.1.0/angus-activation-1.1.0.jar
echo Build should download from $ANGUS_BUNDLE_URL

bash -x $WORKSPACE/docker/build_activationtck.sh

# update bundles links upstream
#rm $SCRIPTPATH/../bundles/jakarta-activation-tck-*
#ln -s -t $SCRIPTPATH/../bundles $OUTPUT/*.zip
