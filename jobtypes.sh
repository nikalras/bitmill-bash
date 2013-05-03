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
