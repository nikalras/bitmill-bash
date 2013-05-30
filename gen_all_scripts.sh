#!/bin/bash

./jobtypes.sh  | grep '"type" :' | cut -f4 -d'"' | while read jobtype; do ./gen_script.sh $jobtype > ${jobtype}.sh; done
