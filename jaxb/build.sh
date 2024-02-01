#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

echo -----------------------------------------------------------------------
echo Scriptpath: ${SCRIPTPATH}
echo -----------------------------------------------------------------------

init_urls

PORTING=$SCRIPTPATH/jaxb-tck
OUTPUT=$PORTING/bundles

# be aware, that in the new version (since 4.0.2), defining $TCK_BUNDLE_BASE_URL causes the run_jaxbtck.sh script to stop in the middle (some way for specific script?)
if [ -z "$TCK_BUNDLE_BASE_URL" ]; then
  export TCK_BUNDLE_BASE_URL=http://localhost:8000
fi
if [ -z "$JAXB_TCK_VERSION" ]; then
  # still no value? STOP
  echo 'Specify $JAXB_TCK_VERSION before running this script, e.g. "4.0.1", used for tag name in JAXB git.'
  exit 1
fi
if [ -z "$TCK_BUNDLE_FILE_NAME" ]; then
  # use the name from init_urls
  export TCK_BUNDLE_FILE_NAME=$JAXB_TCK_NAME
fi
if [ -z "$TCK_BUNDLE_FILE_NAME" ]; then
  # still no value? STOP
  echo 'Specify $JAXB_TCK_NAME before running this script, name of the JAXB TCK filename to download'
  exit 1
fi

if [ ! -d jaxb-tck ]; then
  echo "Cloning JAXB git"
  git clone https://github.com/eclipse-ee4j/jaxb-tck
  cd jaxb-tck
  echo "Checking out version $JAXB_TCK_VERSION"
  git checkout $JAXB_TCK_VERSION
  echo "Git clone and checkout done"
fi

rm -f $PORTING/latest-glassfish.zip
rm -rf $OUTPUT
rm -rf $PORTING/dist/
rm -rf $PORTING/payara6

export WORKSPACE=$PORTING
export GF_BUNDLE_URL=$PAYARA_URL
echo Build should download from $GF_BUNDLE_URL

# Substitute payara6 for glassfish7 for line: $GF_HOME/glassfish7/glassfish/
sed -i "s/glassfish7/payara6/g" "$WORKSPACE/docker/build_jaxbtck.sh"

# echo "Downloading Payara as the official script stopped to do it, storing to `pwd`"
# cd jaxb-tck
# wget --progress=bar:force --no-cache $GF_BUNDLE_URL -O latest-glassfish.zip
# cd ..

bash -x $WORKSPACE/docker/build_jaxbtck.sh
