#!/bin/bash

# Purpose of this file is to have better control over environment options on developer's system.
# Uncomment and edit values as required.
# Usage example (run websocket tests against Payara 5.2020.4):
# ./tck.sh 5.2020.4 websocket

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export ANT_HOME=/usr/share/ant
export JDK=jdk11

# Ant and Java used for everything; maven is used from host's mvn command
export PATH=$JAVA_HOME/bin:$ANT_HOME/bin/:$PATH

# This payara version will be tested as vi (vendor implementation)
export PAYARA_VERSION="$1"

# This file will replace the configuration of the appserver
#export PAYARA_LOGGING_PROPERTIES="$(pwd)/logging.properties"

# Enable debugging of the Payara server under test
# After everything is configured, the script asks user to connect the debugger and hit the ENTER key.
# TCK tests then start and will pause on the first breakpoint
#export PAYARA_DEBUG=true

# log communication with the appserver in Ant configuration phase
#export AS_DEBUG=true

# Payara will start with --verbose, so stdout will be visible right in the output of this console
# useful with the JVM debug output (ie with -verbose:class or -Djava.net.debug=all)
#export PAYARA_VERBOSE=true

# TCK will print what it does (at least something)
#export HARNESS_DEBUG=true

# TCK client logging.properties
export CLIENT_LOGGING_PROPERTIES="$(pwd)/client-logging.properties"

# Start the server if it is not started yet
./bundles/run_server.sh || true &

# Wait a second for the server startup
sleep 1
./run.sh $2 $3 $4 $5 $6

