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

echo "Setting up max.classes.restart"
if grep "^max.classes.restart=" ${WORKSPACE}/build.properties
then
  echo "max.classes.restart settings already exists"
else
  echo "# The restarts can cause issues -- once fixed, remove the max.classes.restart settings" >> ${WORKSPACE}/build.properties
  echo "max.classes.restart=10000" >> ${WORKSPACE}/build.properties
fi

echo Build should download from $GF_BUNDLE_URL
bash -x $WORKSPACE/docker/build_cditck.sh

# update bundles links upstream
rm $SCRIPTPATH/../bundles/cdi-tck-*-porting*
ln -s -t $SCRIPTPATH/../bundles $OUTPUT/*.zip
