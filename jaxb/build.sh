#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

echo -----------------------------------------------------------------------
echo Scriptpath: ${SCRIPTPATH}
echo -----------------------------------------------------------------------

init_urls

PORTING=$SCRIPTPATH/jaxb-tck
OUTPUT=$PORTING/bundles

if [ ! -d jaxb-tck ]; then
   git clone https://github.com/eclipse-ee4j/jaxb-tck
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
  export TCK_BUNDLE_FILE_NAME=jakarta-xml-binding-tck-4.0.0.zip
fi

# Substitute payara6 for glassfish7 for line: $GF_HOME/glassfish7/glassfish/
sed -i "s/glassfish7/payara6/g" "$WORKSPACE/docker/build_jaxbtck.sh"

bash -x $WORKSPACE/docker/build_jaxbtck.sh

echo Deleting file due to TCK Challenge: https://github.com/jakartaee/jaxb-tck/issues/82
# TCK Challenge
# https://github.com/jakartaee/jaxb-tck/issues/82
echo "Current path:"
pwd
echo "Deleting IDREFS_length006_395 test"
rm jaxb-tck/xml_schema/tests/xml_schema/msData/datatypes/Facets/Schemas/IDREFS_length006.xsd
rm jaxb-tck/xml_schema/tests/xml_schema/msData/datatypes/Facets/Schemas/jaxb/IDREFS_length006_395.test.xml
rm jaxb-tck/xml-binding-tck/tests/xml_schema/msData/datatypes/Facets/Schemas/IDREFS_length006.xsd
rm jaxb-tck/batch-multiJVM/work/xml_schema/msData/datatypes/Facets/Schemas/jaxb/IDREFS_length006_395_IDREFS_length006_395.jtr
echo "Preparation completed"

