#!/bin/bash

# A script to push a rendered oacdp site to it's final destination.

set -e   # have the script exit on the first error.

function usage() {
  echo "$0: <destdir>"
  echo "  where <destdir> = a webviewable directory."
}

if [ ! -d "out" ]
then
    usage
    echo ""
    echo "This script should be run in the root directory of" 
    echo "your checkout of the oacdp project after webgen has"
    echo "been run.  I don't see an \"out\" directory, so I'm"
    echo "aborting..."
    exit 1
fi

destdir="$1"

# If no destdir is given then display the usage and exit.
if [ -z "$destdir" ]
then
    usage
    exit 2
fi

# if we supply any flags then show usage.
if [ "${destdir:0:1}" == "-" ]
then
    usage
    exit 0
fi

# If the destdir does not exist try to create it.
if [ ! -d "$destdir" ]
then
    echo "Destination directory, $destdir, wasn't found.  Creating it."
    mkdir $destdir
fi

# we now assume that we can grab the contents of "out/" and install them in $destdir
tar -C out/ -c . | tar -C $destdir -x

exit 0