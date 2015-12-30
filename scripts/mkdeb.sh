#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"/..
source scripts/common.sh

# Require two args
if [[ $# < 2 ]]; then
	cat <<EOF
Create a .deb file of https://github.com/luxas/kubernetes-on-arm

Usage:
scripts/mkdeb.sh [output] [git_ref] [revision]

Arguments:
output: May be a disc or partition or absolute path
git_ref: A commit, tag or branch in the repo
revision: The package revision. Just a number like 2

Examples:
scripts/mkdeb.sh /dev/sda master 1 [/dev/sda1 automatically chosen]
scripts/mkdeb.sh /dev/sda2 dev 2
scripts/mkdeb.sh /etc/debs v0.6.2 1
EOF
	exit
fi

# Build the image
kube-config build kubernetesonarm/make-deb

# Run the container
CID=$(docker run -it kubernetesonarm/make-deb $1 $2)

# Get the directory we should put the file in
OUTDIR=$(parse-path-or-disc $1)

# Copy out the whole folder that includes the .deb
docker cp $CID:/build-deb .

# Copy the .deb package to the output
cp build-deb/*.deb $OUTDIR

# And remove the intermediate directory and container
rm -r build-deb
docker rm $CID

# Last, clean up the directory
cleanup-path-or-disc