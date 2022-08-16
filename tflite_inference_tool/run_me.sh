#!/bin/bash

adb push ./build/model_test /data/local/tmp

adb push ./model_files/Dense_3D_tf2-9.tflite /data/local/tmp

adb push ./model_files/Dense_3D_tf2-3.tflite /data/local/tmp

adb shell "cd /data/local/tmp && LD_LIBRARY_PATH=. ./model_test"
