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

# This script was auto-generated on Fri Apr 19 16:17:40 PDT 2013
# using the command:
# ./gen_script.sh mpileup

function gen_json
{
cat <<EOF
{
  "type" : "mpileup",
  "parameters" : [ {
    "name" : "db",
    "value" : "$1"
  } ],
  "inputs" : [ {
    "name" : "bam",
    "url" : "$2"
  }, {
    "name" : "bai",
    "url" : "$3"
  } ],
  "outputs" : [ {
    "name" : "bcf",
    "url" : "$4"
  } ]
}
EOF
}

if [ $# -ne 4 ] ; then
	echo "Usage: $0 <db> <bam> <bai> <bcf>"
	exit 1
fi

. $(dirname $0)/bitmill
gen_json $1 $(s3_to_url $2) $(s3_to_url $3) $(s3_to_url $4) | postJobAndWait