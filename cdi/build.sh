#!/bin/bash -x

if [ ! -d cditck-porting ]; then
   git clone https://github.com/payara/cditck-porting
fi

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

init_urls

PORTING=$SCRIPTPATH/cditck-porting
OUTPUT=$PORTING/bundles

rm $PORTING/latest-glassfish.zip
rm -rf $OUTPUT
rm -rf $PORTING/dist/
rm -rf $PORTING/payara5


export WORKSPACE=$SCRIPTPATH/cditck-porting
export GF_BUNDLE_URL=$PAYARA_URL
echo Build should download from $GF_BUNDLE_URL
bash -x $WORKSPACE/docker/build_cditck.sh

# update bundles links upstream
rm $SCRIPTPATH/../bundles/cdi-tck-*-porting*
ln -s -t $SCRIPTPATH/../bundles $OUTPUT/*.zip