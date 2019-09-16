# Experiments

| Experiments | Training data set | Testing data set |
| ----------- | ----------------- | ---------------- |
| 1-1 to 1-10 |  user traces (5000 positive + 20000 negative) + simulated traces (5000 positive) | user traces (900 positive + 4000 negative) |
| 2-1 to 2-10 | user traces (5000 positive + 20000 negative) | user traces (900 positive + 4000 negative) |

## Simple Conv. Neural Net

* Net structure


* Training parameters

| Parameter Name | Value |
| ------------------- | ---- |
| Optimization method | ADAM |
| Learning rate | 0.0001 |
| Training Patience | 5 |
| Param. initializer | GLOROT |

* Testing results

| Expt | Sensitivity | Specificity | Precision | Concordance |
| ---- | ----------- | ----------- | ----------- | ----------- |
| 1-1  | 99.9% | 99.9% | 99.9% | 99.9% | 
| Average | 80% | 96% | 90.5% |  99.9% | 

| Expt | Sensitivity | Specificity | Precision | Concordance |
| ---- | ----------- | ----------- | ----------- | ----------- |
| 2-1  | 99.9% | 99.9% | 99.9% | 99.9% | 
| Average | 80% | 96% | 90.5% |  99.9% | 

## AlexNet

## Recursive Neural Net - LSTM

## Trace Segmentation - LSTM

