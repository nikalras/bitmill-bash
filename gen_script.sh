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

if [ $# -ne 1 ]; then
    echo "Usage: $0 <job_type>"
    echo "  Generates a skeleton script for running the given job type"
    exit 1
fi

. $(dirname $0)/bitmill

job_type_template=$(bitmill_curl -f -s https://$BITMILL_SERVER/$BITMILL_API_VERSION/pools/$BITMILL_POOL/jobtypes/$1)
if [ $? -ne 0 ] ; then
	echo "Trouble retrieving job definition for $1"
	# Run again to show error:
	bitmill_curl https://$BITMILL_SERVER/$BITMILL_API_VERSION/pools/$BITMILL_POOL/jobtypes/$1
	exit 1
fi

param_names=$(echo "${job_type_template}" | grep -F '"name" :' | sed -e 's/.*"name"\s*:\s* "\([^"]*\)".*/\1/')

cat <<OUTER_EOF
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

# This script was auto-generated on $(date)
# using the command:
# $0 $@

function gen_json
{
cat <<EOF
OUTER_EOF
echo "$job_type_template" | perl -p -e 'if ($_ =~ /"(value|url)" : ".*"/) {$num++; $_ =~ s/"(value|url)" : ".*"/"\1" : "\$$num"/;}' 

cat <<OUTER_EOF
EOF
}

if [  "x\$1" == "x-w" -o "y\$1" == "y--wait" ] ; then
    WAIT="wait"
    shift
else
    WAIT="async"
fi

if [ \$# -ne $(echo "$param_names" | wc -l) ] ; then
	echo "Usage: \$0 [-w|--wait] <$(echo $param_names | sed -e 's/\s\s*/> </g')>"
	exit 1
fi

. \$(dirname \$0)/bitmill
OUTER_EOF

function generate_gen_json
{
    echo -n "gen_json "
    
    num=1
    for name in ${param_names} ; do
    	if echo "$job_type_template" | grep -A1 -F "\"name\" : \"$name\"" | grep url >/dev/null; then
    		echo -n "\$(s3_to_url \$${num}) "
    	else
    		echo -n "\$${num} "
    	fi
    	num=$((num+1))
    done
}

echo 'if [ "x${WAIT}" == "xwait" ] ; then '
echo "    " $(generate_gen_json) " | postJobAndWait"
echo 'else'
echo "    " $(generate_gen_json) " | postJob "
echo 'fi'
