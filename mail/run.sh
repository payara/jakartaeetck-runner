#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

init_urls

export PORTING=$SCRIPTPATH/mail-tck
OUTPUT=$PORTING/bundles

rm $PORTING/latest-glassfish.zip
rm -rf mail-tck/payara6

export WORKSPACE=$PORTING
export GF_BUNDLE_URL=$PAYARA_URL
echo Build should download from $GF_BUNDLE_URL

if [ -z "$TCK_BUNDLE_BASE_URL" ]; then
  export TCK_BUNDLE_BASE_URL=http://localhost:8000
fi
if [ -z "$TCK_BUNDLE_FILE_NAME" ]; then
  export TCK_BUNDLE_FILE_NAME=mail-tck-2.1_latest.zip
fi

if [ -z $MAVEN_HOME ]; then
    export MAVEN_HOME=`mvn -v | sed -n 's/Maven home: \(.\+\)/\1/p'`
fi

# Replace default value of ${$GF_TOPLEVEL_DIR} (glassfish7) with payara6
sed -i "s/glassfish7/payara6/g" "$WORKSPACE/docker/run_mailtck.sh"

# Make sure the script doesn't unset JAVA_HOME
if [ -z "$JDK11_HOME" ]; then
  export JDK11_HOME=${JAVA_HOME}
fi

if [ -z "$RUNTIME" ]; then
  # Lowercase f intentional - that's what run_mailtck.sh specifically checks for
  export RUNTIME=Glassfish
fi

# Start Mail container
JAMES_CONTAINER=`docker ps -f name='james-mail' -q`
if [ -z "$JAMES_CONTAINER" ]; then
    echo "Starting email server Docker container"
    docker run --name james-mail --rm -d -p 1025:1025 -p 1143:1143 --entrypoint=/bin/bash jakartaee/cts-mailserver:0.1 -c /root/startup.sh
    sleep 10
    echo "Initializing container"
    docker exec -it james-mail /bin/bash -c /root/create_users.sh
fi

bash -x $WORKSPACE/docker/run_mailtck.sh | tee $WORKSPACE/mail.log

if [ ! -d "$SCRIPTPATH/../results" ]; then
    mkdir $SCRIPTPATH/../results
fi

TIMESTAMP=`date -Iminutes | tr -d :`
report=$SCRIPTPATH/../results/mail-$TIMESTAMP.tar.gz
echo Creating report $report
tar zcf $report $WORKSPACE/payara6/glassfish/domains/domain1/logs