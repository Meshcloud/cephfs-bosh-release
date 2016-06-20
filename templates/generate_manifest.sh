#!/bin/bash
#generate_manifest.sh

usage () {
    echo "Usage: generate_manifest.sh bosh-lite|aws ceph-client-keyring-stub director-stub"
    echo " * default"
    exit 1
}

if [[  "$1" != "bosh-lite" && "$1" != "aws" || -z $3 ]]
  then
    usage
fi

if [ "$1" == "bosh-lite" ]
  then
    MANIFEST_NAME=cephfs-boshlite-manifest

    spiff merge templates/cephfs-manifest-boshlite.yml \
    $2 \
    $3 \
    > $MANIFEST_NAME.yml
fi

if [ "$1" == "aws" ]
  then
    MANIFEST_NAME=cephfs-aws-manifest

    spiff merge templates/cephfs-manifest-aws.yml \
    $2 \
    $3 \
    > $MANIFEST_NAME.yml
fi

echo manifest written to $PWD/$MANIFEST_NAME.yml
