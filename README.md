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
docker build -f Dockerfile.drivers -t openhorizon/aarch64-tx1-drivers:jetpack3.3 .
```
3. Build additional interim images with CUDA, CUDNN, and OpenCV libs

```    
docker build -f Dockerfile.cudabase -t openhorizon/aarch64-tx1-cudabase:jetpack3.3 .    # (Required for darknet and caffe)    
```    

4. [optional] Build Caffe
```
cd caffe
docker build -f Dockerfile.caffe -t openhorizon/aarch64-tx1-caffe:jetpack3.3 .
```

5. [optional] Build Darknet (with Yolo)
```
cd darknet
docker build -f Dockerfile.darknet -t openhorizon/aarch64-tx1-darknet:jetpack3.3 .
```

#### Validating that you can successfully run docker + cuda + caffe
1. To run the base jetson-tx1 container:
```
docker run --rm -it openhorizon/aarch64-tx1-drivers:jetpack3.3 /bin/bash
```
It contains the basic drivers but not cuda libraries and as such, is not super useful.  It could be, however, a starting point in trimming down other containers.

2. The Caffe container is `caffe-tx1:latest` and TensorRT (latest optimized runtime for the jetson) container is `openhorizon/tensorrt-tx1`

To test the caffe performance on the GPU:
```
docker run --privileged --rm openhorizon/aarch64-tx1-caffe:jetpack3.3 build/tools/caffe time --model=models/bvlc_alexnet/deploy.prototxt --gpu=0
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
docker run --privileged --rm openhorizon/aarch64-tx1-caffe:jetpack3.3 build/tools/caffe time --model=models/bvlc_alexnet/deploy.prototxt
```
it should be much slower this time, e.g.
```
I1113 22:09:18.295492     1 caffe.cpp:412] Average Forward pass: 7486.12 ms.
I1113 22:09:18.295527     1 caffe.cpp:414] Average Backward pass: 7393.8 ms.
I1113 22:09:18.295565     1 caffe.cpp:416] Average Forward-Backward: 14880.1 ms.
```


#### Validating that you can successfully run docker + cuda + darknet / yolo:

On a TX1, full strength Yolo overwhelms available memory. Try it out with yolov3-tiny.
Assuming you have an attached webcam (not the integrated one, at "-c 0"):
```
xhost + && docker run --privileged -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --rm openhorizon/aarch64-tx1-darknet:jetpack3.3 ./darknet detector demo -c 1 cfg/coco.data cfg/yolov3-tiny.cfg yolov3-tiny.weights
```
Or to test on one picture (it works even if you don't have X):
```
xhost + && docker run --privileged -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --rm openhorizon/aarch64-tx1-darknet:jetpack3.3 ./darknet detect cfg/yolov3-tiny.cfg yolov3-tiny.weights data/dog.jpg
```
