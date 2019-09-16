# Experiments

| Experiments | Training data set | Testing data set |
| ----------- | ----------------- | ---------------- |
| 1-1 to 1-10 |  user traces (5000 positive + 20000 negative) + simulated traces (5000 positive) | user traces (900 positive + 4000 negative) |
| 2-1 to 2-10 | user traces (5000 positive + 20000 negative) | user traces (900 positive + 4000 negative) |

## Simple Conv. Nural Net
* Training parameters

| Parameter Name | Value |
| ------------------- | ---- |
| Optimization method | ADAM |
| Learning rate | 0.0001 |
| Training Patience | 5 |
| param. initializer | GLOROT |

* Testing results

| Expt | Sensitivity | Specificity | Concordance | - | Expt | Sensitivity | Specificity | Concordance |
| ---- | ----------- | ----------- | ----------- | - | ---- | ----------- | ----------- | ----------- |
| 1-1  | 99.9%       | 99.9%       | 99.9%       |   | 2-1  | 99.9%       | 99.9%       | 99.9%       |
| 1-2  | 99.9%       | 99.9%       | 99.9%       |   | 2-1  | 99.9%       | 99.9%       | 99.9%       |
| 1-3  | 99.9%       | 99.9%       | 99.9%       |   | 2-1  | 99.9%       | 99.9%       | 99.9%       |
| 1-4 | 99.9%       | 99.9%       | 99.9%       |   | 2-1  | 99.9%       | 99.9%       | 99.9%       |
| 1-5 | 99.9%       | 99.9%       | 99.9%       |   | 2-1  | 99.9%       | 99.9%       | 99.9%       |
| 1-6 | 99.9%       | 99.9%       | 99.9%       |   | 2-1  | 99.9%       | 99.9%       | 99.9%       |
| 1-7 | 99.9%       | 99.9%       | 99.9%       |   | 2-1  | 99.9%       | 99.9%       | 99.9%       |
| 1-8 | 99.9%       | 99.9%       | 99.9%       |   | 2-1  | 99.9%       | 99.9%       | 99.9%       |
| 1-9 | 99.9%       | 99.9%       | 99.9%       |   | 2-1  | 99.9%       | 99.9%       | 99.9%       |
| 1-10 | 99.9%       | 99.9%       | 99.9%       |   | 2-1  | 99.9%       | 99.9%       | 99.9%       |
| Average | 80% | 96% | 90.5% | | 80% | 96% | 90.5% |
