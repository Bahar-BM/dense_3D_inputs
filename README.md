# openCL crash in models converted by the newer versions of TF (e.g. TF 2.9)

This repo contains scripts and a tool to reproduce the openCL delegate issue with `Dense` layers when they are fed by 3D inputs. 

Converting models in which there is at least one `Dense` layer fed by a 3D input should be done using older versions of TensorFlow (e.g. v2.3 or v2.4). Otherwise, the obtained TFLite model will crash with the OpenCL delegate with this error message:

`ERROR: TfLiteGpuDelegate Init: FULLY_CONNECTED: Amount of input data should match weights width`

OpenCL delegate needs the inputs to the fully-connected layers to be in 2D format. It means that 3D inputs (e.g. 1x23x1024) need to be reshaped into 2D format (e.g. 23x1024) before entering the fully-connected layers. The tflite converter in TF version <= 2.4 (we have tested 2.4 and 2.3) adds extra Reshape layers before and after the fully-connected layers to take care of this issue. However, the new versions (e.g. TF v2.9) do not add these Reshape layers and it leads to a crash with the OpenCL delegate.

Here is a very simple example. Consider the following keras model:

![keras_ver](https://user-images.githubusercontent.com/45400368/184657331-600732a4-ffa4-40e5-bfd3-880adcfc0058.png)

If you convert this model using TF v2.3, you will get the following structure:

![tflite2-3](https://user-images.githubusercontent.com/45400368/184657470-15f374db-b879-48f3-80f1-981473acb788.png)

However, if you use TF v2.9 to convert the above-mentioned keras model, you will get the following structure which will crash with the openCL delegate:

![tflite2-9](https://user-images.githubusercontent.com/45400368/184657539-9d56fc24-9f22-423f-b58c-83cac8ad9ff8.png)


## Building and converting the model
* `model_files` folder contains a very simple model containing a `Dense` node and its corresponding tflite versions (FP16). One version is obtained using TF 2.9 and the other one is obtained using TF 2.3.
  * You can also use `generate_dummy_model.py` to build the model and use `convert_model.py` to convert it to tflite.

## tflite_inference tool 
We have implemented a small tool to feed an input to our sample tflite model (converted by TF 2.9) using `openCL` delegate.

### PREREQUISITES: ###
* Linux host computer
* Connectivity to the target device via adb
* Android NDK, version 22 or later
* CMake 3.18 or later

### BUILD INSTRUCTIONS ###
* Unzip the `tensorflow_lite_cpp_2_9_1_nightly.zip` file inside the `tflite_inference_tool` folder.
* In a terminal, from `tflite_inference_tool` folder:
```console
$ mkdir build
$ cd build
$ cmake -G "Unix Makefiles"
        -DCMAKE_SYSTEM_NAME=Android 
        -DANDROID_ABI=arm64-v8a 
        -DANDROID_STL=c++_shared 
        -DANDROID_NATIVE_API_LEVEL=27 
        -DCMAKE_VERBOSE_MAKEFILE=ON 
        -DCMAKE_TOOLCHAIN_FILE=<path-to-ndk>/build/cmake/android.toolchain.cmake 
        -DCMAKE_BUILD_TYPE=Release
        -DTensorFlowLite_ROOT=../tensorflow_lite_cpp_2_9_1_nightly ..
$ make
```
* Here, you must replace <path-to-ndk> with the absolute path of the ndk installed on your computer. If you installed NDK through Android studio, it is typically located at:
    `/home/<username>/Android/Sdk/ndk/<version>/` on Linux

* `tensorflow_lite_cpp_2_9_1_nightly` is TensorflowFlow Lite library (nightly version) package.
### Run INSTRUCTIONS ###
WARNING: This step will write to your `/data/local/tmp` folder on device. Please make sure existing files in that folder are backed up as needed.

In a terminal, from `tflite_inference_tool` folder:
```console
$ ./run_me.sh
```

The output should be something like this:
```console
INFO: Created TensorFlow Lite delegate for GPU.
INFO: Initialized TensorFlow Lite runtime.
VERBOSE: Replacing 2 node(s) with delegate (TfLiteGpuDelegateV2) node, yielding 1 partitions.
ERROR: TfLiteGpuDelegate Init: FULLY_CONNECTED: Amount of input data should match weights width
INFO: Created 0 GPU delegate kernels.
ERROR: TfLiteGpuDelegate Prepare: delegate is not initialized
ERROR: Node number 2 (TfLiteGpuDelegateV2) failed to prepare.
ERROR: Restored original execution plan after delegate application failure.
Segmentation fault 
```

NOTE: If in `main.cpp` you change line 22 to `TfLiteModel* model = TfLiteModelCreateFromFile("./Dense_3D_tf2-3.tflite");` (which means using the tflite model converted by TF 2.3) and build and run the project again, you will not get any error.
