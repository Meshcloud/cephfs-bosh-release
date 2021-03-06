#!/bin/bash
set -e 

path=$(dirname $0)

cd $path
bosh -e vbox create-release --force

bosh -e vbox upload-release

bosh -e vbox -d cephfs deploy -n manifests/cephfs-dev-local.yml
