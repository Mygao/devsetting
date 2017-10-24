#!/bin/bash

set -e

if [ ! $ROOT ];then
    if [ ! -d 'install_scripts' ];then
        ROOT=$(pwd)/..
    else
        ROOT=$(pwd)
    fi
fi

source $ROOT/envset.sh

PWD=$(pwd)
WORKDIR=$HOME/.lib

cd $WORKDIR
REPO_URL=https://github.com/mariusmuja/flann
TAG=$(git ls-remote --tags $REPO_URL | awk -F/ '{print $3}' | grep -v '{}' | grep -v '-' | sort -V | tail -n1)
FOLDER="flann-${TAG}"
if [ ! -d $FOLDER ]; then 
  curl -LO $REPO_URL/archive/${TAG}.zip
  unzip -q ${TAG}.zip && rm -rf ${TAG}.zip
fi
cd $FOLDER && mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME/.local ..
make -j$(nproc) && make install