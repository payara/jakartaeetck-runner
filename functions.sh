apply_overrides () {
    OVERRIDE_TEMP=`tempfile`
    ## We create a sed program, that we'll execute against ts.jte.
    # TODO: Non-matching single-line / multiline replacements
    sed -n -E '
# single-line to single-line rewrite - create a simple s#prop=anything#prop=override#  
s/^([[:alnum:].]+)=(.+[^\\])$/s#^\1=.+#\1=\2#/p
# mutli-line to multi-line rewrite - create a c command for range
/^([[:alnum:].]+)=(.+\\)/ {
    # print the change command on the first line
<<<<<<< HEAD
    s#^([[:alnum:].]+)=.+#/^\1=.+\\\\$/,/[^\\\\]$/ c\\&#
=======
    s#^([[:alnum:].]+)=.+#/^\1=.+\\\\$/,/[^\\\\]$/ c\\\n&#
>>>>>>> d0de424e4b2bbd0fb3965fed5c151794e6ec4c8c
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
    rm $OVERRIDE_TEMP
}