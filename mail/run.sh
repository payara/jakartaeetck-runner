#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. $SCRIPTPATH/../functions.sh

init_urls

export PORTING=$SCRIPTPATH/mail-tck
OUTPUT=$PORTING/bundles

rm $PORTING/latest-glassfish.zip
rm -rf mail-tck/payara7

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

# Replace default value of ${$GF_TOPLEVEL_DIR} (glassfish7) with payara7
sed -i "s/glassfish7/payara7/g" "$WORKSPACE/docker/run_mailtck.sh"

# fix broken running script - paths to JTreport and JTwork
sed -i 's/echo "1 mail-tck $HOST"/echo "1 html $HOST"/g' "$WORKSPACE/docker/run_mailtck.sh"
sed -i 's#$WORKSPACE/JTreport/mail-tck#$WORKSPACE/mail-tck/JTreport#g' "$WORKSPACE/docker/run_mailtck.sh"
sed -i 's#$WORKSPACE/JTreport#$WORKSPACE/mail-tck/JTreport#g' "$WORKSPACE/docker/run_mailtck.sh"
sed -i 's#$WORKSPACE/JTwork/mail-tck#$WORKSPACE/mail-tck/JTwork#g' "$WORKSPACE/docker/run_mailtck.sh"
sed -i 's#$WORKSPACE/JTwork#$WORKSPACE/mail-tck/JTwork#g' "$WORKSPACE/docker/run_mailtck.sh"

# create path to junitreports-pluggability
sed -i 's#^\(mkdir -p $WORKSPACE/results/junitreports/\)#\1\nmkdir -p $WORKSPACE/results/junitreports-pluggability/#g' "$WORKSPACE/docker/run_mailtck.sh"
# run JTReportParser also for JTreport-Pluggability
sed -i 's#^\(.*\)\(JTReportParser.jar\)\(.*\)#\1\2\3\n\1\2 $WORKSPACE/args.txt $WORKSPACE/mail-tck/JTreport-Pluggability $WORKSPACE/results/junitreports-pluggability/#g' "$WORKSPACE/docker/run_mailtck.sh"
# add pluggability results to the final tar
sed -i 's#^\(tar .*\)\(mail-tck-results.tar.gz\)\(.*\)\(JTreport\)\(.*\)\(junitreports\)/#\1\2\3\4\5\6 $WORKSPACE/mail-tck/JTreport-Pluggability $WORKSPACE/results/junitreports-pluggability/#g' "$WORKSPACE/docker/run_mailtck.sh"

# Replace default download and unzip location to workspace rather than .
sed -i 's/-O latest-glassfish\.zip/-O ${WORKSPACE}\/latest-glassfish\.zip/g' "$WORKSPACE/docker/run_mailtck.sh"
sed -i 's/unzip -q -o latest-glassfish\.zip/unzip -q -o ${WORKSPACE}\/latest-glassfish\.zip -d ${WORKSPACE}/g' "$WORKSPACE/docker/run_mailtck.sh"

# Replace default chmod to workspace rather than .
sed -i 's/chmod -R 777 ${TOP_GLASSFISH_DIR}/chmod -R 777 ${WORKSPACE}\/${TOP_GLASSFISH_DIR}/g' "$WORKSPACE/docker/run_mailtck.sh"

# Make sure the script doesn't unset JAVA_HOME
if [ -z "$JDK11_HOME" ]; then
  export JDK11_HOME=${JAVA_HOME}
fi

if [ -z "$RUNTIME" ]; then
  # Lowercase f intentional - that's what run_mailtck.sh specifically checks for
  export RUNTIME=Glassfish
fi

# Set MAIL_USER
if [ -z "$MAIL_USER" ]; then
  export MAIL_USER="user01@james.local"
fi

# Start Mail container
JAMES_CONTAINER=`docker ps -f name='james-mail' -q`
if [ -z "$JAMES_CONTAINER" ]; then
    echo "Starting email server Docker container"
    docker run --name james-mail --rm -d -p 1025:1025 -p 1143:1143 --entrypoint=/bin/bash jakartaee/cts-mailserver:0.1 -c /root/startup.sh
    sleep 60
    echo "Initializing container"
    docker exec -it james-mail /bin/bash -c /root/create_users.sh
fi

echo "****** Running docker/run_mailtck.sh"
bash -x $WORKSPACE/docker/run_mailtck.sh | tee $WORKSPACE/mail.log

# Stop the Mail container
docker kill james-mail

if [ ! -d "$SCRIPTPATH/../results" ]; then
    mkdir $SCRIPTPATH/../results
fi

TIMESTAMP=`date -Iminutes | tr -d :`
report=$SCRIPTPATH/../results/mail-$TIMESTAMP.tar.gz
echo Creating report $report
tar zcf $report $WORKSPACE/payara7/glassfish/domains/domain1/logs

# generate stage log
cat > $SCRIPTPATH/../stage_mail << EOF
### mail

\`\`\`
`sed -n '/Completed running/,+4 p' $WORKSPACE/mail.log`
\`\`\`
EOF
