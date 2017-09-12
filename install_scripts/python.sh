#!/bin/bash

PYTHONE_DONE=

set -e

if [ ! -d configurations ];then
    ROOT=$(pwd)/..
else
    ROOT=$(pwd)
fi

if [ ! $GIT_DONE ];then
    source "$ROOT/install_scripts/git.sh"
fi

echo "Pyenv installation.. pwd: $PWD, root: $ROOT"

mkdir -p $HOME/.lib

export PYENV_ROOT="$HOME/.pyenv"
export PATH=$PYENV_ROOT/bin:$PATH
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash

set +e

env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv -s install 2.7.13
env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv -s install 3.6.1

echo "---"
echo "Type \"source $ENVFILE\""

set -e

PYTHONE_DONE=1
