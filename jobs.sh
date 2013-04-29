#!/bin/sh

if [ $# -gt 1 -o "x$1" == "x-h" -o "x$1" ==  "x--help" ]; then
    echo "Usage: $0 [JOB_ID]"
    echo "  If job_id is specified, returns details for that specific job."
    echo "  Otherwise, returns details for all jobs."
    exit 1
fi

. $(dirname $0)/bitmill

job_status_or_fail $1
exit_code=$?
if [ $exit_code -ne 0 ] ; then
    echo Job $1 is invalid >&2
    exit 1
fi
