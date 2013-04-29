#!/bin/sh

if [ $# -ne 1 -o "x$1" == "x-h" -o "x$1" ==  "x--help" ]; then
    echo "Usage: $0 JOB_ID"
    echo "  Attempts to cancel the specified job"
    exit 1
fi

. $(dirname $0)/bitmill

attempt_cancel $1

for iter in $(seq 1 5); do
    if ! (job_status $1 | grep -e \"finished\" -e \"failed\" -e \"cancelled\" >/dev/null) ; then
        sleep 1
    else
        break
    fi
done

echo "Job exited with status: $(job_status $1 | grep \"status\" | cut -f4 -d\")"
