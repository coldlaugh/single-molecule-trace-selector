# Transfer Learning Experiment Results
We use transfer learning to demonstrate the capacity of our trained model to generalize to new datasets. In this experiment, we use a new dataset unseen by our trained LSTM models during its training. To apply our model to this new dataset, we use the trained LSTM models as base models, training them on a small portion of the new dataset using transfer learning and evaluate the transfer-learned models using confusion matrices and FRET histograms.

## Description of dataset

| Figure In Paper | System Description | ML Usage Description | Trace Counting |
| ----- | ------ | ------ |  ---- |
| Fig.4(b1) | b_1_No M2+_100 uM EDTA | Only used in evaluation |  |
| Fig.4(b2) | b_2_500 uM Mg2+ | Only used in evaluation| |
| Fig.4(b3) | b_3_1 mM Mg2+ | Only used in evaluation| |
| Fig.5(a1) | a_1 mM Mg2+_100uM Mn2+ | 30% used in transfer training, the rest used in evaluation | |
| Fig.5(c)  | c_100 uM Mn2+ only | Only used in evaluation| |


