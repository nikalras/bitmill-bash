#!/bin/sh

# Copyright (c) 2013 Numerate, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
