#!/bin/bash
##################################################################
# 
# written by haitao.yao @ 2011-09-18.11:02:31
# 
# this is used to stop the perf test 
# 
##################################################################
current_dir="$(cd $(dirname $0);pwd)"
. $current_dir/../lib/env.sh

function print_help()
{
	echo
	echo "$0 - Stop the perf test"
	echo "Usage: $0 -n perf_test_name -i perf_test_uuid"
	echo
	printf "\t-n\t the perf test name in deploy folder\n"
	printf "\t-i\t the perf test uuid, if not known, use status.sh to find it out\n"
	echo
}

while getopts ":n:u:" OPT
do
	case $OPT in
		n)
			perf_test_name=$OPTARG
			;;
		u)
			perf_test_uuid=$OPTARG
			;;
		:)
			print_help
			exit 1
			;;
		?)
			print_help
			;;
	esac
done
if [ -z "$perf_test_name" -o -z "$perf_test_uuid" ]
then
	print_help
	exit 1
fi

if [ ! -d "$PERF_RUNNER_DEPLOY_DIR/$perf_test_name" ]
then
	echo "invalid perf test name"
	echo
	print_help
	exit 1
fi

cd $PERF_RUNNER_DEPLOY_DIR/$perf_test_name

for server_group in $(ls |sort)
do
	if [ ! -d $server_group ]
	then
		continue
	fi
	echo "stop perf unit: $server_group"	
	for server_address in $(get_server_address $server_group/servers.conf)
	do
		echo "stop perf_test: $perf_test_name @ $server_address: "
		ssh $server_address "bash $PERF_RUNNER_LIB_DIR/stop_perf_test.sh $perf_test_name $server_group $perf_test_uuid"
	done
	echo
done
bash $PERF_RUNNER_LIB_DIR/gather_result.sh $perf_test_name $perf_test_uuid
bash $PERF_RUNNER_LIB_DIR/cleanup_result.sh $perf_test_name $perf_test_uuid
