#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

echo -----------------------------------------------------------------------
echo Scriptpath: ${SCRIPTPATH}
echo -----------------------------------------------------------------------

init_urls

PORTING=$SCRIPTPATH/ditck-porting
OUTPUT=$PORTING/bundles

rm -f $PORTING/latest-glassfish.zip
rm -rf $OUTPUT
rm -rf $OUTPUT/../dist/
rm -rf ditck-porting/payara5

export WORKSPACE=$SCRIPTPATH/ditck-porting
export GF_BUNDLE_URL=$PAYARA_URL

echo Build should download from $GF_BUNDLE_URL

bash -x $WORKSPACE/docker/build_ditck.sh

# update bundles links upstream
rm $SCRIPTPATH/../bundles/330-tck-*
ln -s -t $SCRIPTPATH/../bundles $OUTPUT/*.zip
