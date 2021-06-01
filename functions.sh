#
# Copyright (c) 2019,2021 Payara Foundation and/or its affiliates. All rights reserved.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v. 2.0, which is available at
# http://www.eclipse.org/legal/epl-2.0.
#
# This Source Code may also be made available under the following Secondary
# Licenses when the conditions for such availability set forth in the
# Eclipse Public License v. 2.0 are satisfied: GNU General Public License,
# version 2 with the GNU Classpath Exception, which is available at
# https://www.gnu.org/software/classpath/license.html.
#
# SPDX-License-Identifier: EPL-2.0 OR GPL-2.0 WITH Classpath-exception-2.0

apply_overrides () {
    if [[ "$JDK" == "JDK11" || "$JDK" == "jdk11" ]];then
        OVERRIDE_PROP=ts.override.jdk11.properties
    else
        OVERRIDE_PROP=ts.override.properties
    fi
    OVERRIDE_TEMP=`mktemp`
    ## We create a sed program, that we'll execute against ts.jte.
    # TODO: Non-matching single-line / multiline replacements
    sed -n -E '
# single-line to single-line rewrite - create a simple s#prop=anything#prop=override#  
s/^([[:alnum:].]+)=(.+[^\\])$/s#^\1=.+#\1=\2#/p
# mutli-line to multi-line rewrite - create a c command for range
/^([[:alnum:].]+)=(.*\\)/ {
    # print the change command on the first line
    s#^([[:alnum:].]+)=.*#/^\1=.*\\\\$/,/[^\\\\]$/ c\\&#
    :collect
    N
    # while backslash is not last, collect into the buffer
    /[^\\]$/!b collect
    # and print out all the lines,adding extra backslash
    s/\\\n/\\\\&/g
    p
}
' $OVERRIDE_PROP > $OVERRIDE_TEMP
    cat $OVERRIDE_TEMP
    sed -E -f $OVERRIDE_TEMP -i $WORKSPACE/bin/ts.jte
    echo "Changed $WORKSPACE/bin/ts.jte"
    rm $OVERRIDE_TEMP
}

init_urls () {
    if [ -z "$PROFILE" ]; then
        PROFILE=full
    fi
    if [ -z "$BASE_URL" ]; then
        BASE_URL=http://localhost:8000
    fi
    if [ -z "$TCK_URL" ]; then
        TCK_URL=$BASE_URL/jakartaeetck.zip
    fi
    if [ -z "$GLASSFISH_URL" ]; then
        GLASSFISH_URL=$BASE_URL/latest-glassfish.zip
    fi
    if [ -z "$PAYARA_URL" ]; then
        PAYARA_URL=$BASE_URL/payara-prerelease.zip
    fi
    if [ -z "$CDI_TCK_URL" ]; then
        CDI_TCK_URL=$BASE_URL/cdi-tck-3.0.1-dist.zip
    fi
    if [ -z "$DI_TCK_URL" ]; then
        DI_TCK_URL=$BASE_URL/jakarta.inject-tck-2.0.1-bin.zip
    fi
    if [ -z "$BV_TCK_URL" ]; then
        BV_TCK_URL=$BASE_URL/bv-tck-3.0.0-dist.zip
    fi
    if [ -z "$DERBY_URL" ]; then
        DERBY_URL=$BASE_URL/javadb.zip
    fi
    if [ -z "$EJBTIMER_DERBY_SQL" ]; then
        EJBTIMER_DERBY_SQL=$BASE_URL/ejbtimer_derby.sql
    fi
    if [ -z "$JSR352_DERBY_SQL" ]; then
        JSR352_DERBY_SQL=$BASE_URL/jsr352-derby.sql
    fi      
}

make_stage_log () {
    # create a stage file
    stage_name=$2
    if [[ ! -z $3 ]]; then
      stage_name=$2_`echo $3 | tr '/\\&!|' '_'`
    fi
    echo "Writing stage file for $1 $3 into stage_$stage_name"
    cat > stage_$stage_name << EOF 
### $1 $3

\`\`\`
`sed -n '/Completed running/,+3 p' $CTS_HOME/$2.log`
\`\`\`

EOF
}