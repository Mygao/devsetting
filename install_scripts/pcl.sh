#!/usr/bin/env bash
#
#    PCL installer
#
#    Copyright (C) 2017 Gwangmin Lee
#    
#    Author: Gwangmin Lee <gwangmin0123@gmail.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -e

FILENAME=`basename ${BASH_SOURCE[0]}`
FILENAME=${FILENAME%%.*}
DONENAME="DONE$FILENAME"
if [ ! -z ${!DONENAME+x} ];then
  return 0
fi
let DONE$FILENAME=1

ROOT=$(cd $(dirname ${BASH_SOURCE[0]})/.. && pwd)
. $ROOT/envset.sh

if [ -z $SKIPDEPS ];then
  . $ROOT/install_scripts/eigen3.sh
  . $ROOT/install_scripts/flann.sh
  . $ROOT/install_scripts/boost.sh
fi

PWD=$(pwd)
PKG_NAME="pcl"

REPO_URL=https://github.com/PointCloudLibrary/pcl
TAG=$(git ls-remote --tags $REPO_URL | awk -F/ '{print $3}' | grep -v -e '{}' -e 'rc' -e 'ros' | sort -V | tail -n1)
CUSTOMTAGNAME="${PKG_NAME}TAG"
TAG=${!CUSTOMTAGNAME:-$TAG}
VER=$(echo $TAG | sed 's/pcl-//')
FOLDER="$PKG_NAME*"
INSTALLED_VERSION=
VERFILE=$(find / -name 'pcl_common*\.pc' 2>/dev/null | sort -V | tail -n1)
if [ $VERFILE ] && [ -r $VERFILE ];then
  INSTALLED_VERSION=$(pkg-config --modversion $(echo $(basename $VERFILE) | sed 's/\.pc//'))
fi

if ([ ! -z $REINSTALL ] && [ $LEVEL -le $REINSTALL ]) || [ -z $INSTALLED_VERSION ] || [ $INSTALLED_VERSION != $VER ];then
  iecho "$PKG_NAME $VER installation.. install location: $LOCAL_DIR"

  mkdir -p $TMP_DIR && cd $TMP_DIR
  curl --retry 10 -L ${REPO_URL}/archive/${TAG}.tar.gz | tar xz
  cd $FOLDER && mkdir -p build && cd build
  if [ ! -z $VISUALIZATION ];then
    VISUALIZATION=ON
  else
    VISUALIZATION=OFF
  fi
  if cmake --find-package -DCOMPILER_ID=GNU -DLANGUAGE=C -DNAME=OpenGL -DMODE=EXIST;then
    FOUND_OPENGL=ON
  else
    FOUND_OPENGL=OFF
  fi
  PCL_CMAKE_OPTIONS="\
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${LOCAL_DIR} \
    -DWITH_QT=$VISUALIZATION \
    -DWITH_VTK=$VISUALIZATION \
    -DWITH_OPENGL=$FOUND_OPENGL \
    -DPCL_ENABLE_SSE=OFF \
    -DBUILD_tools=OFF \
    "
  BUILDSTATIC="${PKG_NAME}STATIC"
  if [ ! -z ${!BUILDSTATIC} ];then
    PCL_CMAKE_OPTIONS="${PCL_CMAKE_OPTIONS} -DPCL_SHARED_LIBS=OFF -DWITH_OPENGL=OFF"
  fi

  cmake $PCL_CMAKE_OPTIONS ..
  make -s -j${NPROC}
  make -s install 1>/dev/null
  cd $ROOT && rm -rf $TMP_DIR
else
  gecho "$PKG_NAME $VER is already installed"
fi

LEVEL=$(( ${LEVEL}-1 ))
