# Trace selection with SPARTAN

In comparison with our LSTM models, we benchmark the performance of SPARTAN's trace sorting functionality. SPARTAN's trace sorting is based on a hard thresholding method using a pre-defined list of calculated trace features such as signal-to-noise ratio and anti-correlation. We will provide the full list of the calculated trace features in the below sections. 

To use SPARTAN. a user of SPARTAN first finds a set of thresholds using pilot experiment data to filter out as much bad traces as possible while maintaining the good traces in the pool. The user can then apply such "curation" thresholds to the bulk of experiment data. The thresholding algorithm is fast, since the trace features are calculated very efficiently (I think). 

After the "curation" step, the user will need to go over the filtered trace pool to select out good traces. There is no automatic selection / segmentation algorithm in SPARTAN for this step.

Here, we use Shiba's data as an example to benchmark the performance of SPARTAN's hard thresholding method.

## Searching thresholds

Searching a good set of thresholds is the most important step to ensure high performance of SPARTAN. We modified the source code of SPARTAN to load in not only the traces data but also our machine learning data set with human selection labels. This enables us to find good thresholds using "training data" to manually search thresholds. Below is an example of the modified SPARTAN trace sorting interface. 
![SPARTAN trace sortting](finished_spartan/SPARTAN.png)


