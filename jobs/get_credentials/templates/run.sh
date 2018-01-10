#!/bin/bash 
set -x
CLUSTER="/root/ceph-cluster/"
RAN=`shuf -i 2000-65000 -n 1`

set -e
pushd $CLUSTER

if [  -e "$CLUSRER/ceph.conf" ]; then
	ceph osd pool create "cephfs_data_$RANDOM" 128
	ceph osd pool create "cephfs_metadata_$RAN" 128
	ceph fs new "cephfs_$RAN " "cephfs_data_$RAN" "cephfs_data_$RAN"

	if [[ $(ceph mds stat | grep "active") = '' ]]
	then
		echo "Meta Data Service is not active"
        exit 1
	fi

	ceph auth add client.test mon 'allow r' osd 'allow rw pool="cephfs_data_$RAN" allow rw pool="cephfs_data_$RAN"' 

fi
exit 0