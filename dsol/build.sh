#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

echo -----------------------------------------------------------------------
echo Scriptpath: ${SCRIPTPATH}
echo -----------------------------------------------------------------------

init_urls

PORTING=$SCRIPTPATH/dsol-tck
OUTPUT=$PORTING/bundles

if [ ! -d dsol-tck ]; then
   git clone https://github.com/eclipse-ee4j/debugging-support-for-other-languages-tck
fi

rm -f $PORTING/latest-glassfish.zip
rm -rf $OUTPUT
rm -rf $PORTING/dist/
rm -rf $PORTING/payara5

export WORKSPACE=$PORTING
export GF_BUNDLE_URL=$PAYARA_URL
echo Build should download from $GF_BUNDLE_URL

if [ -z "$TCK_BUNDLE_BASE_URL" ]; then
  export TCK_BUNDLE_BASE_URL=http://localhost:8000
fi
if [ -z "$TCK_BUNDLE_FILE_NAME" ]; then
  export TCK_BUNDLE_FILE_NAME=jakarta-debugging-tck-1.0.0.zip
fi

bash -x $WORKSPACE/docker/build_dsoltck.sh