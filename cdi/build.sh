#!/bin/bash

if [ ! -d cditck-porting ]; then
   # For now, use Patrik's for until everything is moved into Payara
   git clone https://github.com/pdudits/cditck-porting
fi

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

init_urls

PORTING=$SCRIPTPATH/cditck-porting
OUTPUT=$PORTING/bundles

rm $PORTING/latest_glassfish.zip
rm -rf $OUTPUT
rm -rf $OUTPUT/../dist/
rm -rf cditck-porting/payara5

export WORKSPACE=$SCRIPTPATH/cditck-porting
export GF_BUNDLE_URL=$PAYARA_URL
echo Build should download from $GF_BUNDLE_URL
bash -x $WORKSPACE/docker/build_cditck.sh

# update bundles links upstream
rm $SCRIPTPATH/../bundles/cdi-tck-*
ln -s -t $SCRIPTPATH/../bundles $OUTPUT/*.zip