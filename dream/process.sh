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

if [ $# -ne 4 ]; then
cat <<EOF
 Usage: $0 [-l log_prefix] <num_simulations> <params.[mat|xml]> <s3_bucket_name> <s3_output_prefix>
 Takes an input parameters file (.mat or .xml) and submits a Dream Challenge job to BitMill for processing.
 Output will be placed in the specified bucket, using the given prefix. Three output files will be generated:
    s3://s3_bucket_name/prefix.mat
    s3://s3_bucket_name/prefix.out
    s3://s3_bucket_name/prefix.err
 containing the job results, stdout and stderr, respectively.
EOF
    exit 1
fi 

numsims=$1
params=$2
bucket=$3
prefix=$4

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

#Grant ACLs to bitmill server's amazon account
s3cmd setacl --acl-grant=read:${BITMILL_SERVER_ACCOUNT} s3://${bucket} >/dev/null
s3cmd setacl --acl-grant=read_acp:${BITMILL_SERVER_ACCOUNT} s3://${bucket} >/dev/null
s3cmd setacl --acl-grant=write:${BITMILL_SERVER_ACCOUNT} s3://${bucket} >/dev/null

#Grant bucket permissions to BitMill account
tmp_cred=$(mktemp) || { echo "Failed to create temp file"; exit 1; }
s3cmd put ${tmp_cred} s3://${bucket}/${BITMILL_USER} >/dev/null

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
fi
s3cmd setacl --acl-grant=read:${BITMILL_SERVER_ACCOUNT} ${s3_param_file} >/dev/null

echo $base_dir/dream_sim.sh \
    $numsims  \
    ${s3_param_file} \
    s3://${bucket}/${prefix}.mat \
    s3://${bucket}/${prefix}.out \
    s3://${bucket}/${prefix}.err

if [ $? -eq 0 ] ; then    
    echo "To check on the status of the job, run ${base_dir}/jobs.sh <job_id>."
    echo "When finished, the output files can be downloaded using the following commands:"
    echo " s3cmd get s3://${bucket}/${prefix}.mat"
    echo " s3cmd get s3://${bucket}/${prefix}.out" 
    echo " s3cmd get s3://${bucket}/${prefix}.err"
    echo "To request cancellation of the job, run ${base_dir}/cancel.sh <job_id>."
fi
