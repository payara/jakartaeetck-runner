#!/bin/bash

if [ ! -d bvtck-porting ]; then
   git clone https://github.com/payara/bvtck-porting
fi

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

echo -----------------------------------------------------------------------
echo Scriptpath: ${SCRIPTPATH}
echo -----------------------------------------------------------------------

init_urls

PORTING=$SCRIPTPATH/bvtck-porting
OUTPUT=$PORTING/bundles

rm -f $PORTING/latest-glassfish.zip
rm -rf $OUTPUT
rm -rf $OUTPUT/../dist/
rm -rf bvtck-porting/payara5

export WORKSPACE=$SCRIPTPATH/bvtck-porting
export GF_BUNDLE_URL=$PAYARA_URL
echo Build should download from $GF_BUNDLE_URL
bash -x $WORKSPACE/docker/build_bvtck.sh

# update bundles links upstream
rm $SCRIPTPATH/../bundles/bv-tck-*
ln -s -t $SCRIPTPATH/../bundles $OUTPUT/*.zip
