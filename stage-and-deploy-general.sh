#!/bin/bash
set -e 

path=$(dirname $0)

cd $path
bosh create-release --force

bosh upload-release

bosh -d cephfs deploy -n manifests/cephfs-dev-local.yml