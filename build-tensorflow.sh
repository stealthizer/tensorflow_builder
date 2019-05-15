#!/bin/bash
# Patrick Wieschollek

# =============================================================
# UPDATE SOURCE
# =============================================================
#git checkout -- .
#git pull origin master

jobs=2
#compute=6.1,5.2,3.5,3.0
compute=3.0

TF_ROOT=/tensorflow
output_dir=${TF_ROOT}/pip/tensorflow_pkg

for python_version in "python3"; do

  echo "build TensorFlow for Python version: $python_version" 

  # =============================================================
  # CONFIGURATION
  # =============================================================
  

  cd $TF_ROOT

  export PYTHON_BIN_PATH=$(which ${python_version})
  export PYTHON_LIB_PATH="$($PYTHON_BIN_PATH -c 'import site; print(site.getsitepackages()[0])')"
  export PYTHONPATH=${TF_ROOT}/lib
  export PYTHON_ARG=${TF_ROOT}/lib
  export CUDA_TOOLKIT_PATH=/usr/local/cuda
  export CUDNN_INSTALL_PATH=/usr
  export TMP=/tmp

  export TF_NEED_GCP=0
  export TF_NEED_CUDA=1
  export TF_CUDA_VERSION="$($CUDA_TOOLKIT_PATH/bin/nvcc --version | sed -n 's/^.*release \(.*\),.*/\1/p')"
  export TF_CUDA_COMPUTE_CAPABILITIES=$compute
  export TF_NEED_HDFS=0
  export TF_NEED_OPENCL=0
  export TF_NEED_JEMALLOC=1
  export TF_ENABLE_XLA=0
  export TF_NEED_VERBS=0
  export TF_CUDA_CLANG=0
  export TF_CUDNN_VERSION="$(sed -n 's/^#define CUDNN_MAJOR\s*\(.*\).*/\1/p' $CUDNN_INSTALL_PATH/include/cudnn.h)"
  export TF_NEED_MKL=0
  export TF_DOWNLOAD_MKL=0
  export TF_NEED_AWS=0
  export TF_NEED_MPI=0
  export TF_NEED_GDR=0
  export TF_NEED_S3=0
  export TF_NEED_OPENCL_SYCL=0
  export TF_SET_ANDROID_WORKSPACE=0
  export TF_NEED_COMPUTECPP=0
  export GCC_HOST_COMPILER_PATH=$(which gcc)
  export CC_OPT_FLAGS="-march=native"
  #export TF_SET_ANDROID_WORKSPACE=0
  export TF_NEED_KAFKA=0
  export TF_NEED_TENSORRT=0

  # when using NCCL you need to install it own your own
  export TF_NCCL_VERSION=1.3

  export GCC_HOST_COMPILER_PATH=$(which gcc)
  export CC_OPT_FLAGS="-march=native"


  # =============================================================
  # BUILD NEW VERSION
  # =============================================================
  bazel clean

  ./configure

  # build TensorFlow (add  -s to see executed commands)
  # "--copt=" can be "-mavx -mavx2 -mfma  -msse4.2 -mfpmath=both"
  # build entire package
  echo "Building Package"
  bazel build -s -c opt --jobs=$jobs --copt=-mfpmath=both --copt=-mavx --copt=-mavx2 --copt=-mfma --config=cuda //tensorflow/tools/pip_package:build_pip_package
  echo "Building c++ library"
  # build c++ library
  bazel build  -c opt --jobs=$jobs --copt=-mfpmath=both --copt=-mavx --copt=-mavx2 --copt=-mfma --config=cuda  tensorflow:libtensorflow_cc.so
  # build TF pip package
  echo "Building TF pip package"
  bazel-bin/tensorflow/tools/pip_package/build_pip_package $output_dir

done
