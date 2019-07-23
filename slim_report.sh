#!/bin/bash
#
# This reduces result tar.gz by removing osgi-cache from the archive
#

DIR=`dirname $1`
BASE=`basename $1 | sed -e "s/.tar\|.gz//g"`

gzip -cd $1 | tar --delete --no-anchored --wildcards osgi-cache | gzip > $DIR/$BASE.slim.tar.gz
