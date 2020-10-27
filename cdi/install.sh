#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

init_urls

rm -rf $DIST
mkdir -p $DIST

# wget into dist
if [ ! -f $DIST/$CDI_TCK_DIST-dist.zip ]; then
    wget $CDI_TCK_URL -P $DIST
fi

unzip $DIST/$CDI_TCK_DIST-dist.zip -d $DIST > /dev/null

GROUP_ID=jakarta.enterprise
CDI_TCK_DIST=cdi-tck-${CDI_TCK_VERSION}
TCK_ARTIFACTS=$DIST/$CDI_TCK_DIST/artifacts

cd $WORKSPACE

# Build and Install the glassfish-porting-master to local repo
rm -fr glassfish-cdi-porting-tck-master 
wget https://github.com/eclipse-ee4j/glassfish-cdi-porting-tck/archive/master.zip -O glassfish-cdi-porting-tck.zip
unzip -q glassfish-cdi-porting-tck.zip
cd glassfish-cdi-porting-tck-master
mvn --global-settings "${PORTING}/settings.xml" clean install

# Parent pom
mvn --global-settings "${PORTING}/settings.xml" org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
-Dfile=$TCK_ARTIFACTS/cdi-tck-parent-${CDI_TCK_VERSION}.pom \
-DgroupId=${GROUP_ID} \
-DartifactId=cdi-tck-parent \
-Dversion=${CDI_TCK_VERSION} \
-Dpackaging=pom

# Porting Package APIs for CDI TCK
mvn --global-settings "${PORTING}/settings.xml" org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
-Dfile=$TCK_ARTIFACTS/cdi-tck-api-${CDI_TCK_VERSION}.jar \
-Dsources=$TCK_ARTIFACTS/cdi-tck-api-${CDI_TCK_VERSION}-sources.jar \
-Djavadoc=$TCK_ARTIFACTS/cdi-tck-api-${CDI_TCK_VERSION}-javadoc.jar

# CDI TCK Installed Library - test bean archive
mvn --global-settings "${PORTING}/settings.xml" org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
-Dfile=$TCK_ARTIFACTS/cdi-tck-ext-lib-${CDI_TCK_VERSION}.jar

# CDI TCK Test Suite
mvn --global-settings "${PORTING}/settings.xml" org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
-Dfile=$TCK_ARTIFACTS/cdi-tck-impl-${CDI_TCK_VERSION}.jar \
-Dsources=$TCK_ARTIFACTS/cdi-tck-impl-${CDI_TCK_VERSION}-sources.jar

mvn --global-settings "${PORTING}/settings.xml" install:install-file \
-Dfile=$TCK_ARTIFACTS/cdi-tck-impl-${CDI_TCK_VERSION}-suite.xml \
-DgroupId=${GROUP_ID} \
-DartifactId=cdi-tck-impl \
-Dversion=${CDI_TCK_VERSION} \
-Dpackaging=xml \
-Dclassifier=suite

mvn --global-settings "${PORTING}/settings.xml" org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
-Dfile=$DIST/${CDI_TCK_DIST}/weld/jboss-tck-runner/src/test/tck20/tck-tests.xml \
-DgroupId=${GROUP_ID} \
-DartifactId=cdi-tck-impl \
-Dversion=${CDI_TCK_VERSION} \
-Dpackaging=xml



