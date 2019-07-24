apply_overrides () {
    OVERRIDE_TEMP=`tempfile`
    ## We create a sed program, that we'll execute against ts.jte.
    # TODO: Multiline props. Please use something else than sed to implement that ;)
    sed -n -E "s/^([[:alnum:].]+)=(.+)/s#^\1=.\\\+#\1=\2#/p " ts.override.properties > $OVERRIDE_TEMP
    cat $OVERRIDE_TEMP
    sed -f $OVERRIDE_TEMP -i $WORKSPACE/bin/ts.jte
    rm $OVERRIDE_TEMP
}