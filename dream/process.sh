#!/bin/bash
log_prefix=

while :
do
	case $1 in
		-l )
			log_prefix=$2
			shift 2
			;;
		*)
			break
			;;
	esac
done

if [ $# -ne 3 ]; then
cat <<EOF
 Usage: $0 [-l log_prefix] <params.[mat|xml]> <s3_bucket_name> <s3_output_prefix>
 Takes an input parameters file (.mat or .xml) and submits a Dream Challenge job to BitMill for processing.
 Output will be placed in the specified bucket, using the given prefix. Four output files will be generated:
    s3://s3_bucket_name/prefix_predictions.mat
    s3://s3_bucket_name/prefix_distances.mat
    s3://s3_bucket_name/prefix.out
    s3://s3_bucket_name/prefix.err
 containing the simulation predictions, distances, stdout and stderr, respectively.
EOF
    exit 1
fi 

params=$1
bucket=$2
prefix=$3

export log_prefix=${log_prefix:-$prefix}
base_dir=$(cd $(dirname $0)/..; pwd)
source ${base_dir}/bitmill

if ! hash s3cmd 2>/dev/null; then
	logerr "Couldn't find s3cmd on path!"
	exit 1
fi

if ! s3cmd info s3://$bucket/ >/dev/null; then
	logerr "Couldn't succesfully use s3cmd to check the bucket, please make sure it's configured!"
	exit 1
fi

if [ ! -e ${params} ] ; then
    logerr "Couldn't read parameter file ${params}. Check the path is correct!"
    exit 1
fi

log "$0 $@ PID=$$"

param_hash=$(md5sum ${params} -b 2>/dev/null | cut -f1 -d' ')
if [ "x${param_hash}" == "x" ] ; then
    param_hash=$(stat -c%Z ${params} 2>/dev/null)
fi
if [ "x${param_hash}" == "x" ] ; then
    param_hash=$(date +%s)
fi

param_extension="${params##*.}"
param_file=${prefix}_param_${param_hash}.${param_extension}
s3_param_file="s3://${bucket}/${param_file}"
if ! s3cmd info ${s3_param_file} &>/dev/null ; then
    s3cmd put ${params} ${s3_param_file}  &>/dev/null
    s3cmd setacl --acl-grant=read:${BITMILL_SERVER_ACCOUNT} ${s3_param_file} >/dev/null
fi

$base_dir/dream_sim.sh \
    ${BITMILL_NOTIFY_EMAIL:-no_email_specified} \
    ${s3_param_file} \
    s3://${bucket}/${prefix}_predictions.mat \
    s3://${bucket}/${prefix}_distances.mat \
    s3://${bucket}/${prefix}.out \
    s3://${bucket}/${prefix}.err

if [ $? -eq 0 ] ; then    
    echo "To check on the status of the job, run ${base_dir}/jobs.sh <job_id>."
    echo "When finished, the output files can be downloaded using the following commands:"
    echo " s3cmd get s3://${bucket}/${prefix}_predictions.mat"
    echo " s3cmd get s3://${bucket}/${prefix}_distances.mat"
    echo " s3cmd get s3://${bucket}/${prefix}.out" 
    echo " s3cmd get s3://${bucket}/${prefix}.err"
    echo "To request cancellation of the job, run ${base_dir}/cancel.sh <job_id>."
fi
