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

# This script was auto-generated on Fri Apr 19 16:17:38 PDT 2013
# using the command:
# ./gen_script.sh bytecount_mt

function gen_json
{
cat <<EOF
{
  "type" : "bytecount_mt",
  "inputs" : [ {
    "name" : "input",
    "url" : "$1"
  } ],
  "outputs" : [ {
    "name" : "num_bytes",
    "url" : "$2"
  } ]
}
EOF
}

if [ $# -ne 2 ] ; then
	echo "Usage: $0 <input> <num_bytes>"
	exit 1
fi

. $(dirname $0)/bitmill
gen_json $(s3_to_url $1) $(s3_to_url $2) | postJobAndWait
