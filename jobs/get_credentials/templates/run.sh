#!/bin/bash 
set -x
FIRSTMON=<%= link('ceph-storage').instances.first.address %>

ssh $FIRSTMON 'bash -s' < EOF
CLUSTER="/root/ceph-cluster/"
RAN=`shuf -i 2000-65000 -n 1`

set -e
pushd $CLUSTER

ceph osd pool create "cephfs_data_$RAN" 128
ceph osd pool create "cephfs_metadata_$RAN" 128
ceph fs new "cephfs_$RAN " "cephfs_data_$RAN" "cephfs_data_$RAN"

if [[ $(ceph mds stat | grep "active") = '' ]]
then
	echo "Meta Data Service is not active"
	exit 1
fi

ceph auth add client.test mon 'allow r' osd 'allow rw pool="cephfs_data_$RAN" allow rw pool="cephfs_data_$RAN"' 
ceph auth list
exit 0
EOF