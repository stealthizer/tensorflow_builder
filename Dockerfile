# Copyright 2018 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================
#
# THIS IS A GENERATED DOCKERFILE.
#
# This file was assembled from multiple pieces, whose use is documented
# throughout. Please refer to the TensorFlow dockerfiles documentation
# for more information.

ARG UBUNTU_VERSION=18.04

FROM nvidia/cuda:10.0-base-ubuntu${UBUNTU_VERSION} as base

# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cuda-command-line-tools-10-0 \
        cuda-cublas-10-0 \
        cuda-cufft-10-0 \
        cuda-curand-10-0 \
        cuda-cusolver-10-0 \
        cuda-cusparse-10-0 \
        cuda-cufft-dev-10-0 \
        cuda-cublas-dev-10-0 \
        cuda-curand-dev-10-0 \
        cuda-cusolver-dev-10-0 \
        cuda-cusparse-dev-10-0 \
        nvidia-headless-no-dkms-418 \
        libcudnn7=7.4.1.5-1+cuda10.0 \
        libcudnn7-dev=7.4.1.5-1+cuda10.0 \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libpng-dev \
        libzmq3-dev \
        pkg-config \
        software-properties-common \
        unzip \
	wget \
	software-properties-common \
	swig \
	openjdk-8-jdk \
	git \
	nvinfer-runtime-trt-repo-ubuntu1804-5.0.2-ga-cuda10.0 \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends libnvinfer5=5.0.2-1+cuda10.0 \
	&& rm -rf /var/lib/apt/lists/*

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

# FOR CUDNN

ARG PYTHON=python3
ARG PIP=pip3

# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y \
    ${PYTHON} \
    ${PYTHON}-pip \
    && rm -rf /var/lib/apt/lists/*

# Some TF tools expect a "python" binary
RUN ln -s $(which ${PYTHON}) /usr/local/bin/python 

RUN ${PIP} --no-cache-dir install --upgrade \
    pip \
    setuptools \
    numpy \
    six \
    wheel \
    mock \
    scipy \
    h5py \
    enum34

RUN ${PIP} install keras_applications==1.0.5 --no-deps \ 
        && ${PIP} install  keras_preprocessing==1.0.3 --no-deps

# Install Bazel itself
RUN wget https://github.com/bazelbuild/bazel/releases/download/0.19.2/bazel-0.19.2-installer-linux-x86_64.sh \
	&& chmod +x ./bazel-0.19.2-installer-linux-x86_64.sh \
	&& ./bazel-0.19.2-installer-linux-x86_64.sh

# Clone Tensorflow
RUN git clone https://github.com/tensorflow/tensorflow \
	&& cd tensorflow \
	&& git checkout r1.13

WORKDIR /tensorflow

COPY build-tensorflow.sh /tensorflow

RUN  chmod +x build-tensorflow.sh 

ENTRYPOINT ["/tensorflow/build-tensorflow.sh"]