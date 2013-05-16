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

# This script was auto-generated on Thu May 16 16:17:20 PDT 2013
# using the command:
# ./gen_script.sh hmm_align

function gen_json
{
cat <<EOF
{
  "type" : "hmm_align",
  "inputs" : [ {
    "name" : "fa",
    "url" : "$1"
  }, {
    "name" : "hmm",
    "url" : "$2"
  } ],
  "outputs" : [ {
    "name" : "result",
    "url" : "$3"
  } ]
}
EOF
}

if [  "x$1" == "x-w" -o "y$1" == "y--wait" ] ; then
    WAIT="wait"
    shift
else
    WAIT="async"
fi

if [ $# -ne 3 ] ; then
	echo "Usage: $0 <fa> <hmm> <result>"
	exit 1
fi

. $(dirname $0)/bitmill
if [ "x${WAIT}" == "xwait" ] ; then 
     gen_json $(s3_to_url $1) $(s3_to_url $2) $(s3_to_url $3)  | postJobAndWait
else
     gen_json $(s3_to_url $1) $(s3_to_url $2) $(s3_to_url $3)  | postJob 
fi
