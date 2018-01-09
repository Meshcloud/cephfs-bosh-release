#!/bin/bash 
set -x
CLUSTER="/root/ceph-cluster/"
RANDOM=`shuf -i 2000-65000 -n 1`

set -e
pushd $CLUSTER

if [ ! -e "ceph.conf" ]; then
	ceph osd pool create "cephfs_data_$RANDOM" 128
	ceph osd pool create "cephfs_metadata_$RANDOM" 128
	ceph fs new "cephfs_$RANDOM " "cephfs_data_$RANDOM" "cephfs_data_$RANDOM"

	if[[ !``ceph mds stat` | grep "active"` = '' ]]; then
		exit 1
	fi	

	ceph auth add client.test mon 'allow r' osd 'allow rw pool="cephfs_data_$RANDOM" allow rw pool="cephfs_data_$RANDOM"' 

fi
exit 0