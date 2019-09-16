#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

init_urls

CDI_TCK_VERSION=2.0.6
PORTING=$SCRIPTPATH/cditck-porting
OUTPUT=$PORTING/bundles
DIST=$PORTING/dist
CDI_TCK_DIST=cdi-tck-$CDI_TCK_VERSION

rm -rf $DIST/$CDI_TCK_DIST

# wget into dist
if [ ! -f $DIST/$CDI_TCK_DIST-dist.zip ]; then
    wget $CDI_TCK_URL -P $DIST
fi

unzip $DIST/$CDI_TCK_DIST-dist.zip -d $DIST > /dev/null

TCK_ARTIFACTS=$DIST/$CDI_TCK_DIST/artifacts
GROUP_ID=org.jboss.cdi.tck

# Parent pom
mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
-Dfile=$TCK_ARTIFACTS/cdi-tck-parent-${CDI_TCK_VERSION}.pom -DgroupId=org.jboss.cdi.tck \
-DartifactId=cdi-tck-parent -Dversion=${CDI_TCK_VERSION} -Dpackaging=pom

# Porting Package APIs for CDI TCK
mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
-Dfile=$TCK_ARTIFACTS/cdi-tck-api-${CDI_TCK_VERSION}.jar -Dsources=$TCK_ARTIFACTS/cdi-tck-api-${CDI_TCK_VERSION}-sources.jar \
-Djavadoc=$TCK_ARTIFACTS/cdi-tck-api-${CDI_TCK_VERSION}-javadoc.jar

# CDI TCK Installed Library - test bean archive
mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
-Dfile=$TCK_ARTIFACTS/cdi-tck-ext-lib-${CDI_TCK_VERSION}.jar

# CDI TCK Test Suite
mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
-Dfile=$TCK_ARTIFACTS/cdi-tck-impl-${CDI_TCK_VERSION}.jar -Dsources=$TCK_ARTIFACTS/cdi-tck-impl-${CDI_TCK_VERSION}-sources.jar

mvn install:install-file \
-Dfile=$TCK_ARTIFACTS/cdi-tck-impl-${CDI_TCK_VERSION}-suite.xml \
-DgroupId=${GROUP_ID} \
-DartifactId=cdi-tck-impl \
-Dversion=${CDI_TCK_VERSION} \
-Dpackaging=xml \
-Dclassifier=suite



