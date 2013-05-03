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
