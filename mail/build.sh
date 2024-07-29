#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

echo -----------------------------------------------------------------------
echo Scriptpath: ${SCRIPTPATH}
echo -----------------------------------------------------------------------

init_urls

PORTING=$SCRIPTPATH/mail-tck
OUTPUT=$PORTING/bundles

if [ ! -d mail-tck ]; then
  git clone https://github.com/jakartaee/mail-tck
  cd mail-tck
  git checkout c57f734856b3dc7b5313d997dc7805ff95dc5c32
  cd ..
fi

rm -f $PORTING/latest-glassfish.zip
rm -rf $OUTPUT
rm -rf $PORTING/dist/
rm -rf $PORTING/payara7

export WORKSPACE=$PORTING
export GF_BUNDLE_URL=$PAYARA_URL
echo Build should download from $GF_BUNDLE_URL

if [ -z "$TCK_BUNDLE_BASE_URL" ]; then
  export TCK_BUNDLE_BASE_URL=http://localhost:8000
fi
if [ -z "$TCK_BUNDLE_FILE_NAME" ]; then
  export TCK_BUNDLE_FILE_NAME=mail-tck-2.1_latest.zip
fi

bash -x $WORKSPACE/docker/build_mailtck.sh
