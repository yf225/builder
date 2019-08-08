#!/usr/bin/env bash

set -ex

export TH_BINARY_BUILD=1
export USE_CUDA=0

# Keep an array of cmake variables to add to
if [[ -z "$CMAKE_ARGS" ]]; then
    # These are passed to tools/build_pytorch_libs.sh::build()
    CMAKE_ARGS=()
fi
if [[ -z "$EXTRA_CAFFE2_CMAKE_FLAGS" ]]; then
    # These are passed to tools/build_pytorch_libs.sh::build_caffe2()
    EXTRA_CAFFE2_CMAKE_FLAGS=()
fi

WHEELHOUSE_DIR="wheelhousecpu"
LIBTORCH_HOUSE_DIR="libtorch_housecpu"
if [[ -z "$PYTORCH_FINAL_PACKAGE_DIR" ]]; then
    if [[ -z "$BUILD_PYTHONLESS" ]]; then
        PYTORCH_FINAL_PACKAGE_DIR="/remote/wheelhousecpu"
    else
        PYTORCH_FINAL_PACKAGE_DIR="/remote/libtorch_housecpu"
    fi
fi
mkdir -p "$PYTORCH_FINAL_PACKAGE_DIR" || true

OS_NAME=`awk -F= '/^NAME/{print $2}' /etc/os-release`
if [[ "$OS_NAME" == *"CentOS Linux"* ]]; then
    LIBGOMP_PATH="/usr/lib64/libgomp.so.1"
elif [[ "$OS_NAME" == *"Ubuntu"* ]]; then
    LIBGOMP_PATH="/usr/lib/gcc/x86_64-linux-gnu/5/libgomp.so"
fi

DEPS_LIST=(
    "$LIBGOMP_PATH"
)

DEPS_SONAME=(
    "libgomp.so.1"
)

rm -rf /usr/local/cuda*

# builder/test.sh requires DESIRED_CUDA to know what tests to exclude
export DESIRED_CUDA='cpu'

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/build_common.sh
