#!/bin/bash
check_present() {
    if [ ! -f $1 ]; then
       #echo -e "\e[33mFile $1 is missing.\e[0m TCK may fail unless you provided custom URL to runner."
       echo "Downloading required TCK artifact $1"
       ./download.sh
    fi
}

cd `dirname $0`
check_present jakartaeetck.zip
check_present latest-glassfish.zip
check_present payara-prerelease.zip
check_present cdi-tck-3.0.1-dist.zip
check_present bv-tck-3.0.0-dist.zip
check_present jakarta.inject-tck-2.0.1-bin.zip
check_present javadb.zip
check_present ejbtimer_derby.sql
check_present jsr352-derby.sql
exec python3 -m http.server 8000
