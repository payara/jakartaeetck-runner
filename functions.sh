#
# Copyright (c) 2019,2020 Payara Foundation and/or its affiliates. All rights reserved.
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
' ts.override.properties > $OVERRIDE_TEMP
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
    if [ -z "$PAYARA_URL" ]; then
        PAYARA_URL=$BASE_URL/payara-prerelease.zip
    fi
    if [ -z "$DERBY_URL" ]; then
        DERBY_URL=$BASE_URL/javadb.zip
    fi

    # set *_TCK_BUNDLE_URL here!
    # remove setup from https://github.com/payara/EngineeringJenkinsjobs/blob/dff9a4e26440830394c3dc7f93c701eba8bf1fab/TCK-Suite/Jenkinsfile#L321
    # remove comment https://github.com/payara/EngineeringJenkinsjobs/blob/dff9a4e26440830394c3dc7f93c701eba8bf1fab/TCK-Suite/Jenkinsfile#L314
    TCK_URL=https://download.eclipse.org/jakartaee/platform/8/jakarta-jakartaeetck-8.0.3.zip

    BV_TCK_BUNDLE_URL=http://download.eclipse.org/ee4j/bean-validation/beanvalidation-tck-dist-2.0.5.zip 

    CDI_TCK_URL=http://download.eclipse.org/ee4j/cdi/cdi-tck-2.0.6-dist.zip
    DI_TCK_URL=http://download.eclipse.org/ee4j/cdi/jakarta.inject-tck-1.0-bin.zip
    
    GLASSFISH_URL=https://download.eclipse.org/glassfish/glassfish-5.1.0.zip
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
