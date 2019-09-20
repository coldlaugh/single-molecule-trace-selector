# Experiments

* Experimental Conditions

| Experiments | Training Dataset | Testing Dataset | 
| ----------- | ----------------- | ---------------- | 
| 1-1 to 1-10 |  80% user traces + all simulated traces | 20% user traces |
| 2-1 to 2-10 | 80% user traces | 20% user traces |

* User Traces Statistics

| Experiment System | Accepted Traces | Rejected Traces |
| ---- | ----- | ----- |
| RNA0 | 2050 | 4332 |
| RIB | 2538 | 15688 |
| W3T | 366 | 2896 | 
| HaMMy | 156 | 1369 | 

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
| 1-1  | 75.6% | 93.9% | 73.0% | 90.7% | 
| 1-2  | 66.6% | 95.4% | 75.4% | 90.3% | 
| 1-3  | 74.2% | 94.3% | 73.5% | 90.8% |
| 1-4  | 72.6% | 94.8% | 74.4% | 90.9% |
| 1-5  | 81.0% | 93.2% | 71.1% | 91.1% |
| 1-6  | 72.2% | 95.1% | 76.8% | 90.9% |
| 1-7  | 72.2% | 94.4% | 72.6% | 90.7% |
| 1-8  | 70.6% | 94.3% | 72.9% | 90.1% |
| 1-9  | 75.2% | 94.6% | 75.1% | 91.1% |
| 1-10  | 72.3% | 94.6% | 74.4% | 90.7% |
| Average | 73.3%	| 94.5% |	74.0%	| 90.7%| 

| Expt | Sensitivity | Specificity | Precision | Concordance |
| ---- | ----------- | ----------- | ----------- | ----------- |
| 2-1  | 73.5% | 94.6% | 74.8% | 90.8% | 
| 2-2  | 75.9% | 93.9% | 72.9% | 90.8% | 
| 2-3  | 75.2% | 95.0% | 75.8% | 91.2% | 
| 2-4  | 73.0% | 94.5% | 73.5% | 90.8% | 
| 2-5  | 73.2% | 94.5% | 73.4% | 90.9% | 
| 2-6  | 80.1% | 93.5% | 73.5% | 91.1% | 
| 2-7  | 77.0% | 93.8% | 71.5% | 90.9% | 
| 2-8  | 66.0% | 96.5% | 80.5% | 91.1% | 
| 2-9  | 70.4% | 95.1% | 75.9% | 90.7% | 
| 2-10  | 76.2% | 93.8% | 72.7% | 90.7% | 
| Average |74.1%	| 94.5%	| 74.5%| 	90.9%| 

Average training time: 

## AlexNet

## Recursive Neural Net - LSTM

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
| 1-1  | 72.0% | 95.2% | 76.6% | 91.1% | 
| 1-2  | 73.1% | 94.4% | 73.7% | 90.6% | 
| 1-3  | 74.0% | 93.6% | 71.2% | 90.2% | 
| 1-4  | 66.6% | 94.7% | 72.4% | 89.8% |
| 1-5  | 63.0% | 96.7% | 80.1% | 91.0% |
| 1-6  | 57.8% | 95.0% | 72.3% | 88.2% |
| 1-7  | 68.4% | 94.1% | 70.3% | 89.8% |
| 1-8  | 76.5% | 94.6% | 75.4% | 91.4% |
| 1-9  | 76.4% | 93.5% | 72.0% | 90.3% |
| 1-10  | 72.0% | 93.8% | 71.5% | 90.0% |
| Average | 70.0% |	94.6%	| 73.6% |	90.2%| 

| Expt | Sensitivity | Specificity | Precision | Concordance |
| ---- | ----------- | ----------- | ----------- | ----------- |
| 2-1  | 74.3% | 93.7% | 72.0% | 90.2% | 
| 2-2  | 75.3% | 94.2% | 73.5% | 90.9% | 
| 2-3  | 73.3% | 95.9% | 79.2% | 91.9% | 
| 2-4  | 70.6% | 96.2% | 79.4% | 91.7% | 
| 2-5  | 76.9% | 94.8% | 75.3% | 91.7% | 
| 2-6  | 65.8% | 96.4% | 80.2% | 90.8% |
| 2-7  | 79.2% | 93.0% | 69.7% | 90.6% |
| 2-8  | 76.8% | 94.4% | 74.9% | 91.3% |
| 2-9  | 58.7% | 97.0% | 81.0% | 90.1% |
| 2-10  | 69.0% | 95.6% | 77.0% | 90.9% |
| Average | 72.0% |	95.1%	| 76.2%	| 91.0%| 

Average training time: 

## Trace Segmentation - LSTM

# Results

Here we show the FRET historam obtained using experiment 1-1 as a illustration of the performance of the algorithms.

| Experiment System | FRET histogram |
| ----------------- | -------------- |
| HaMMy | ![](https://github.com/coldlaugh/single-molecule-trace-selector/blob/master/double-channel/experiments/experiment1-1/HaMMy_FRET_hist.png)| 

