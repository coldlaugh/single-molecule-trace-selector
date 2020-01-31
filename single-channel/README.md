# Automated Trace Selector for SimREPS Traces

This project contains executable scripts that construct and train a LSTM neural network to classify traces data from T790 experiments. The executable scripts also visualize testing results from trained neural networks.

## Getting Started

These instructions will help you check prerequisites and setup execution environment for the script.

### Prerequisites

The following prerequisites must be meet in order to run the script:
```
MATLAB >= R2018a
MATLAB Neural Network Toolbox >= 11.1
MATLAB Statistics and Machine Learning Toolbox >= 11.3
```
And [Deep Learning Network Analyzer for Neural Network Toolbox](https://www.mathworks.com/matlabcentral/fileexchange/66982-deep-learning-network-analyzer-for-neural-network-toolbox). <br>
Run the following command in MATLAB to check versions for all installed products:
```
ver
```

### Installing Prerequisites

If you need to install prerequesites, download the newest release of MATLAB. Run the downloaded installer and select the toolboxes. You can also install toolboxes only if your MATLAB version meets the requirement. Simply run the installer of your current release of MATLAB and select the toolboxes needed.

### Setting the Environment

In MATLAB, right click the `src/` folder and choose `add folder and all subfolders to path`. Also, open `settings.json` and the set `workingDir` to the folder one level above the `src/` folder. 

Optionally, you can change the value of `dataFolder`, which defines the path of the folder containing training and testing data. The value is already set for you.

### Before Start

In MATLAB, run
```
test_setup_simreps
```
You will get a confirmation message if everything is setup correctly.

## Running the Script

Running the script is pretty straightforward. Simple run the following command in MATLAB:
```
main_simreps
```
No action is further needed. The script will conduct training and testing of the LSTM neural network.

# License
This project is licensed under the MIT License - see the LICENSE.md file for details