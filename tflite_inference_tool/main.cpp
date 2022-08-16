#include "tensorflow/lite/c/c_api.h"    
#include "tensorflow/lite/delegates/gpu/delegate.h" 
#include <algorithm>
#include <vector>
#include <random>
#include <iostream>
#include <cassert>

int main(void) {
    TfLiteGpuDelegateOptionsV2 opts = TfLiteGpuDelegateOptionsV2Default();
    opts.is_precision_loss_allowed = 1;
    opts.inference_preference = TFLITE_GPU_INFERENCE_PREFERENCE_FAST_SINGLE_ANSWER;
    opts.inference_priority1 = TFLITE_GPU_INFERENCE_PRIORITY_MIN_LATENCY;
    opts.inference_priority2 = TFLITE_GPU_INFERENCE_PRIORITY_AUTO;
    opts.inference_priority3 = TFLITE_GPU_INFERENCE_PRIORITY_AUTO;

    TfLiteDelegate* gpuDelegate = TfLiteGpuDelegateV2Create(&opts);
    TfLiteInterpreterOptions* options = TfLiteInterpreterOptionsCreate();

    TfLiteInterpreterOptionsAddDelegate(options, gpuDelegate);

    TfLiteModel* model = TfLiteModelCreateFromFile("./Dense_3D_tf2-3.tflite");
    TfLiteInterpreter* interpreter = TfLiteInterpreterCreate(model, options);

    std::vector<float> randomInput(1*23*1024);
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<float> dis(0.f, 1.f); 
    std::generate(randomInput.begin(), randomInput.end(), [&](){return dis(gen);});

    TfLiteInterpreterAllocateTensors(interpreter);
    auto* inputTensor = TfLiteInterpreterGetInputTensor(interpreter, 0);

    auto status = TfLiteTensorCopyFromBuffer(inputTensor, randomInput.data(), randomInput.size()*sizeof(float));
    assert(status == kTfLiteOk);

    TfLiteInterpreterInvoke(interpreter);

    std::vector<float> output(1*23*512);
    auto const* outputTensor = TfLiteInterpreterGetOutputTensor(interpreter, 0);

    status = TfLiteTensorCopyToBuffer(outputTensor, output.data(), output.size()*sizeof(float));
    assert(status == kTfLiteOk);

    std::cout<<"Inference was successful!"<<std::endl;

    TfLiteInterpreterDelete(interpreter);
    TfLiteGpuDelegateV2Delete(gpuDelegate);
    TfLiteInterpreterOptionsDelete(options);
    TfLiteModelDelete(model);
}
