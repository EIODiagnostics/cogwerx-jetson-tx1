Many thanks to Dima Rekesh, PhD who is the original author of these builds and write-up.

### For initial Jetson hardware setup instructions, visit the [wiki Home](https://github.com/open-horizon/cogwerx-jetson-tx1/wiki)

### Docker build instructions and files for deep learning container images
* Jetson TX1 (base)
* CUDA, CUDNN, OpenCV and supporting libs, full and lean variants
* Caffe deep learning framework
* Darknet deep learning framework with Yolo

These docker images are also available at the public openhorizon docker hub [repo](https://hub.docker.com/u/openhorizon/) as part of the [Horizon](https://bluehorizon.network) project.



#### To build docker images (each successive image depends on the previous)

1. Clone this repo locally
2. Build Jetson TX1 image. This base image is the prerequisite for later containers using CUDNN, OpenCV, and various deep learning frameworks

```
docker build -t openhorizon/jetson-tx1 .
```
3. Build additional interim images with CUDA, CUDNN, and OpenCV libs

```
cd cuda
docker build -f Dockerfile.cuda.fullcudnn -t openhorizon/cuda-tx1-fullcudnn .    # (Required for darknet and caffe)
```
```
docker build -f Dockerfile.cuda.fullcudnn.opencv -t openhorizon/cuda-tx1-fullcudnn-opencv .  # (Required for darknet and caffe)
```
[optional] build a lean version of CUDA
```
docker build -f Dockerfile.cuda.lean -t openhorizon/cuda-tx1-lean .
```

4. [optional] Build Caffe
```
cd caffe
docker build -t openhorizon/caffe-tx1 .
```

5. [optional] Build Darknet (with Yolo)
```
cd darknet
docker build -t openhorizon/darknet-tx1 .
```

#### Validating that you can successfully run docker + cuda + caffe
1. To run the base jetson-tx1 container:
```
docker run --rm -ti openhorizon/jetson-tx1 bash
```
It contains the basic drivers but not cuda libraries and as such, is not super useful.  It could be, however, a starting point in trimming down other containers.

2. The "lean" cuda enabled container is cuda-tx1-lean  and the container with all cuda libraries installed is `openhorizon/cuda-tx1:full`

3. The Caffe container is `caffe-tx1:latest` and TensorRT (latest optimized runtime for the jetson) container is `openhorizon/tensorrt-tx1`

To test the caffe performance on the GPU:
```
docker run --privileged --rm openhorizon/caffe-tx1 build/tools/caffe time --model=models/bvlc_alexnet/deploy.prototxt --gpu=0
```
If all is well, you should see something like this at the end of your test output:
```
I1113 21:44:42.726897     1 caffe.cpp:412] Average Forward pass: 78.9996 ms.
I1113 21:44:42.727072     1 caffe.cpp:414] Average Backward pass: 115.744 ms.
I1113 21:44:42.727244     1 caffe.cpp:416] Average Forward-Backward: 195.683 ms.
```
The forward pass is the time to run the model.  The backward pass is the time to train it.  Clearly, in this configuration, we are optimized for running models

Now do the same on the CPU:
```
docker run --privileged --rm openhorizon/caffe-tx1 build/tools/caffe time --model=models/bvlc_alexnet/deploy.prototxt
```
it should be much slower this time, e.g.
```
I1113 22:09:18.295492     1 caffe.cpp:412] Average Forward pass: 7486.12 ms.
I1113 22:09:18.295527     1 caffe.cpp:414] Average Backward pass: 7393.8 ms.
I1113 22:09:18.295565     1 caffe.cpp:416] Average Forward-Backward: 14880.1 ms.
```


#### Validating that you can successfully run docker + cuda + darknet / yolo:

Now assuming you have an attached webcam (not the integrated one):
```
xhost + && docker run --privileged -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --rm openhorizon/darknet-tx1 ./darknet yolo demo cfg/tiny-yolo.cfg tiny-yolo.weights
```
Or to test on one picture (it works even if you don't have X):
```
docker run --privileged -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --rm openhorizon/darknet-tx1 ./darknet yolo test cfg/tiny-yolo.cfg tiny-yolo.weights data/person.jpg
```
