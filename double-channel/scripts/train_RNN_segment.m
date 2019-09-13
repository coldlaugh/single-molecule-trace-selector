%% Setting up constants. 

numClasses = 2;
numHiddenUnits = 100;
numStack = 10;

if gpuDeviceCount()
    computeEnv = 'gpu';
else
    computeEnv = 'cpu';
end

expt = '../experiments/experiment1/fileNames.mat';
checkpointFolder = '../net/rnn/checkpoint/';
checkpointFreq = 10;

maxTrainEpochs = 100;
batchSize = 600;
algo = 'adam';
learningRate = 0.0001;
L2Reg = 0.00001;
WeightsInitializer = 'glorot';
dataUsageForTrain = 0.8;
rejectedDropRate = 0.0;

netFolder = '../experiments/experiment1/';
netOutput = 'rnn-LSTM-segment.mat';

%%  setup folders
[~,~] = mkdir(checkpointFolder);
[~,~] = mkdir(netFolder);

%% Setup data store


dataset = load(expt,'-mat');
read = @(loc)load(loc,'data');

% Devide test and train set

numTrain = length(dataset.trainSet);
numTest = length(dataset.testSet);
numTotal = numTrain + numTest;

% Load train / test data from data store

YTrain = cell([numTrain,1]);
YTest = cell([numTest,1]);


XTrain = cell([numTrain,1]);
XTest = cell([numTest,1]);

iTrain = 1;
iTest = 1;

userMsg = waitbar(0,'Reading image data','Name','Reading image data');

for i = 1 : numTrain
    data = read(fullfile(dataset.serialFolder, strcat(dataset.trainSet{i},dataset.serialFormat)));
    data = data.data;
    normFactor = 1 / max([conv(data(1,:),[1/3,1/3,1/3],'same')+conv(data(2,:),[1/3,1/3,1/3],'same')]);
    label = any(reshape(data(3,1:end-mod(end,numStack)), numStack, []));
    data = normFactor * [
        reshape(data(1,1:end-mod(end,numStack)),numStack,[]);
        reshape(data(2,1:end-mod(end,numStack)),numStack,[])
        ];
    XTrain{iTrain} = data;
    YTrain{iTrain} = categorical(label, [1, 0]);
    iTrain = iTrain + 1;
    waitbar(i / numTotal,userMsg);
end

for i = 1 : numTest
    data = read(fullfile(dataset.serialFolder, strcat(dataset.testSet{i},dataset.serialFormat)));
    data = data.data;
    data(1,:) = conv(data(1,:),[1/3,1/3,1/3],'same');
    data(2,:) = conv(data(2,:),[1/3,1/3,1/3],'same');
    normFactor = 1 / max(data(:));
    data = normFactor * [
        reshape(data(1,1:end-mod(end,numStack)),numStack,[]);
        reshape(data(2,1:end-mod(end,numStack)),numStack,[])
        ];
    XTest{iTest} = data;
    YTest{iTest} = categorical(label, [1, 0]);
    iTest = iTest + 1;
    waitbar((numTrain + i) / numTotal,userMsg);
end

close(userMsg);


% sequenceLengths = cellfun(@(X) size(X,2), XTrain);
% [~, idx] = sort(sequenceLengths);
% XTrain = XTrain(idx);
% YTrain = YTrain(idx);
% 
% sequenceLengths = cellfun(@(X) size(X,2), XTest);
% [~, idx] = sort(sequenceLengths);
% XTest = XTest(idx);
% YTest = YTest(idx);

%% Setup net

rnnLayers = [
    sequenceInputLayer(2 * numStack)
    bilstmLayer(numHiddenUnits, 'OutputMode', 'sequence')
    bilstmLayer(numHiddenUnits, 'OutputMode', 'sequence')
    bilstmLayer(numHiddenUnits, 'OutputMode', 'sequence')
    fullyConnectedLayer(floor(numHiddenUnits/4),'WeightLearnRateFactor', 2, 'BiasLearnRateFactor', 2)
    reluLayer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor', 10, 'BiasLearnRateFactor', 10)
    softmaxLayer
    classificationLayer
    ];

options = trainingOptions(...
     algo,...
    'InitialLearnRate',learningRate,...
    'L2Regularization',L2Reg,...
    'MaxEpochs',maxTrainEpochs,...
    'MiniBatchSize',batchSize,...
    'Shuffle','every-epoch',...
    'ExecutionEnvironment',computeEnv,...
    'Plots','training-progress',...
    'ValidationData',{XTest,YTest},...
    'ValidationFrequency',floor(numTrain / batchSize * 2),...
    'ValidationPatience',20,...
    'SequenceLength','shortest',...
    'SequencePaddingValue', 0,...
    'CheckpointPath',''...
);

%% train RNN

[rnnNet,info] = trainNetwork(XTrain,YTrain,rnnLayers,options);
rnnLayers = rnnNet.Layers;
save(fullfile(netFolder, netOutput),'rnnNet','info');

%% classify using RNN
[pred, score] =classify(rnnNet, XTest, 'ExecutionEnvironment', computeEnv, 'MiniBatchSize', batchSize, 'SequenceLength', options.SequenceLength);
label = zeros([length(YTest),1]);
truth = zeros([length(YTest),1]);
for i = 1 : length(YTest)
    if (sum(pred{i} == "1") >= 1) 
        label(i) = 1;
    end
    if any(YTest{i} == "1")
        truth(i) = 1;
    end
end
label = categorical(label);
truth = categorical(truth);
plotconfusion(truth, label);


%% Showing acc curve
