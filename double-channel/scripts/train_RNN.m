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
learningRate = 0.005;
L2Reg = 0.00001;
WeightsInitializer = 'glorot';
dataUsageForTrain = 0.8;
rejectedDropRate = 0.5;

netFolder = '../net/rnn/';
netOutput = 'rnn-LSTM.mat';

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

YTrain = zeros([numTrain,1]);
YTest = zeros([numTest,1]);


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
    YTrain(iTrain) = ~contains(dataset.trainSet{i},'rejected');
    iTrain = iTrain + 1;
    waitbar(i / numTotal,userMsg);
end

for i = 1 : numTest
    data = read(fullfile(dataset.serialFolder, strcat(dataset.testSet{i},dataset.serialFormat)));
    data = data.data;
    normFactor = 1 / max([conv(data(1,:),[1/3,1/3,1/3],'same')+conv(data(2,:),[1/3,1/3,1/3],'same')]);
    label = any(reshape(data(3,1:end-mod(end,numStack)), numStack, []));
    data = normFactor * [
        reshape(data(1,1:end-mod(end,numStack)),numStack,[]);
        reshape(data(2,1:end-mod(end,numStack)),numStack,[])
        ];
    XTest{iTest} = data;
    YTest(iTest) = ~contains(dataset.testSet{i},'rejected');
    iTest = iTest + 1;
    waitbar((numTrain + i) / numTotal,userMsg);
end

YTrain = categorical(YTrain, [1, 0]);
YTest = categorical(YTest, [1, 0]);

close(userMsg);

% sequenceLengths = cellfun(@(X) size(X,2), XTest);
% [~, idx] = sort(sequenceLengths);
% XTest = XTest(idx);
% YTest = categorical(YTest(idx));
% 
% close(userMsg);
%% Setup net

rnnLayers = [
    sequenceInputLayer(2 * numStack)
    bilstmLayer(numHiddenUnits, 'OutputMode', 'sequence')
    bilstmLayer(numHiddenUnits, 'OutputMode', 'sequence')
    bilstmLayer(numHiddenUnits, 'OutputMode', 'last')
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
    'ValidationFrequency',floor(length(indTrain) / batchSize * 2),...
    'ValidationPatience',20,...
    'SequenceLength','longest',...
    'SequencePaddingValue', 0,...
    'CheckpointPath',''...
);

%% train RNN

[rnnNet,info] = trainNetwork(XTrain,YTrain,rnnLayers,options);
rnnLayers = rnnNet.Layers;
save(fullfile(netFolder, netOutput),'rnnNet','indTest','indTrain','info');

%% classify using RNN
[pred, score] =classify(rnnNet, XTest, 'ExecutionEnvironment', computeEnv, 'MiniBatchSize', batchSize, 'SequenceLength', options.SequenceLength);
plotconfusion(YTest, pred);


%% Showing acc curve
figure(1);clf;hold on;
for x = 0 : 0.01 : 1
    acc = sum((score(:,1) > x & YTest == "1")) + sum((score(:,1) < x & YTest == "0"));
    acc = acc / length(pred);
    plot(x, acc, 'bo')
end
hold off;