# Tensorflow GPU compute 3.0 Builder
Last updated: 2019/05/15 for CUDA 10.0 and Tensorflow r1.13

If you are trying to use tensorflow-gpu in a computer that has an old NVIDIA GPU, you may find a message like this:
```
Ignoring visible gpu device (device: 0, name: GeForce GTX 765M, pci bus id: 0000:01:00.0,
compute capability: 3.0) with Cuda compute capability 3.0. The minimum required Cuda capability is 6.0.
```
Also some warnings about the processor may appear too:
```
Your CPU supports instructions that this TensorFlow binary was not compiled to use: AVX AVX2
```
And then you [search](https://stackoverflow.com/questions/50995707/ignoring-visible-gpu-device-with-compute-capability-3-0-the-minimum-required-cu) what happens and end yourself [compiling](https://www.tensorflow.org/install/source) a custom version for your needs with lots of [libraries](http://manpages.ubuntu.com/manpages/bionic/man7/cuda-libraries.7.html) and dependencies that you will never use while risking the actual graphics configuration. For that I've created a docker container that takes care of all this stuff, just specify what computing capability do you need and the CPU instruction set that you want to use.

To run the image (use the one available)
```
$ docker run --init -v $(pwd)/output:/tensorflow/pip/tensorflow_pkg tensorflow-builder:latest
```

And after several hours of compilation (im my case) a new python wheel file will be available for you in the ./output folder, ready to be used.

You can customize you own tensorflow-builder image. Once you have performed your changes you can build it with:

```
docker build -t tensorflow-builder .
```