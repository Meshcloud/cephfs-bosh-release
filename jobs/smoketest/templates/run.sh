#!/bin/bash
FIRSTMON=<%= link('ceph-storage').instances.first.adress %>
apt-get install ceph-common ceph-fs-common -y
mkdir -p /mnt/mycephfs
mount -t ceph $FIRSTMON:/ /mnt/mycephfs -o name=testuser,secret=AQDrWzJae1DGCxAAXGvPgKptRBAIGM3bxztrtw== 