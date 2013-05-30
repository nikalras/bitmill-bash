#!/bin/bash

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

# This script was auto-generated on Thu May 30 11:12:41 PDT 2013
# using the command:
# ./gen_script.sh blastn_enum

function gen_json
{
cat <<EOF
{
  "type" : "blastn_enum",
  "parameters" : [ {
    "name" : "db",
    "value" : "$1"
  }, {
    "name" : "evalue",
    "value" : "$2"
  } ],
  "inputs" : [ {
    "name" : "query",
    "url" : "$3"
  } ],
  "outputs" : [ {
    "name" : "tab",
    "url" : "$4"
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

if [ $# -ne 4 ] ; then
	echo "Usage: $0 [-w|--wait] <db> <evalue> <query> <tab>"
	exit 1
fi

. $(dirname $0)/bitmill
if [ "x${WAIT}" == "xwait" ] ; then 
     gen_json $1 $2 $(s3_to_url $3) $(s3_to_url $4)  | postJobAndWait
else
     gen_json $1 $2 $(s3_to_url $3) $(s3_to_url $4)  | postJob 
fi
