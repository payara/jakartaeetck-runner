#!/bin/bash

if [ ! -d ditck-porting ]; then
   git clone https://github.com/payara/ditck-porting
fi

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

echo -----------------------------------------------------------------------
echo Scriptpath: ${SCRIPTPATH}
echo -----------------------------------------------------------------------

init_urls

PORTING=$SCRIPTPATH/ditck-porting
OUTPUT=$PORTING/bundles

cd $PORTING
git checkout EE9
cd $SCRIPTPATH

rm -f $PORTING/latest-glassfish.zip
rm -rf $OUTPUT
rm -rf $OUTPUT/../dist/
rm -rf ditck-porting/payara6

export WORKSPACE=$SCRIPTPATH/ditck-porting
export GF_BUNDLE_URL=$PAYARA_URL

echo Build should download from $GF_BUNDLE_URL

bash -x $WORKSPACE/docker/build_ditck.sh

# update bundles links upstream
rm $SCRIPTPATH/../bundles/330-tck-*
ln -s -t $SCRIPTPATH/../bundles $OUTPUT/*.zip
