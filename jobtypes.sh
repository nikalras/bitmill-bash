#!/bin/sh

if [ $# -gt 1 -o "x$1" == "x-h" -o "x$1" ==  "x--help" ]; then
    echo "Usage: $0 [JOBTYPE]"
    echo "  Returns details of the specified job type, or details for all job types"
    echo "  if none is specified."
    exit 1
fi

. $(dirname $0)/bitmill

bitmill_curl -f -XGET https://$BITMILL_SERVER/$BITMILL_API_VERSION/pools/$BITMILL_POOL/jobtypes/$1 2> /dev/null
exit_code=$?
if [ $exit_code -ne 0 ] ; then
    echo Jobtype $1 is invalid >&2
    exit 1
fi
