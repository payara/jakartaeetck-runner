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
        CDI_TCK_URL=$BASE_URL/cdi-tck-2.0.6-dist.zip
    fi
    if [ -z "$DI_TCK_URL" ]; then
        DI_TCK_URL=$BASE_URL/jakarta.inject-tck-1.0-bin.zip
    fi    
}

make_stage_log () {
    # create a stage file
    
cat > stage_$2 << EOF 
### $1

\`\`\`
`sed -n '/Completed running/,+3 p' $CTS_HOME/$2.log`
\`\`\`

EOF
}